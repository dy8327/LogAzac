package com.example.logazac;
import static org.junit.jupiter.api.Assertions.*;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.jdbc.core.JdbcTemplate;
import com.logazac.LogazacApplication;
import com.logazac.dto.*;
import com.logazac.mapper.AnalysisMapper;
import com.logazac.service.*;
import tools.jackson.databind.json.JsonMapper;

@SpringBootTest(classes = {LogazacApplication.class, LogazacApplicationTests.TestWebConfig.class}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class LogazacApplicationTests {
    @Autowired JdbcTemplate jdbc;
    @Autowired AnalysisMapper mapper;
    @Autowired AnalysisPersistenceService persistence;
    @Autowired RuleCatalog catalog;
    @Autowired AnalysisService analysis;
    @Autowired PythonAnalyzerService python;
    @Autowired JsonMapper json;
    @BeforeEach void reset() {
        for (String table : List.of("DETECTION_RESULTS", "ANALYSIS_OPERATIONS", "INSPECTIONS", "LOG_FILES", "DETECTION_RULES", "USERS")) jdbc.update("DELETE FROM " + table);
        for (String sequence : List.of("SEQ_LOG_FILES", "SEQ_INSPECTIONS", "SEQ_DETECTION_RESULTS")) jdbc.execute("ALTER SEQUENCE " + sequence + " RESTART WITH 100");
        jdbc.update("INSERT INTO USERS(USER_NO,USER_ID,USER_PW,USER_EMAIL) VALUES(1,'test','hash','test@example.invalid')");
        jdbc.update("INSERT INTO LOG_FILES(FILE_NO,FILE_NAME,FILE_SIZE,USER_NO,SOURCE_TYPE,FILE_PATH) VALUES(1,'sample.log',1,1,'UNKNOWN','test')");
        jdbc.update("INSERT INTO INSPECTIONS(INS_NO,FILE_NO,INS_STATUS) VALUES(1,1,'PROCESSING')");
        jdbc.update("INSERT INTO DETECTION_RULES(DET_NO,DET_RULE_TYPE,DET_PATTERN,DET_DESCRIPTION,LOG_TYPE,USE_YN) VALUES(1,'PRICE_CHANGED','COMPARE','가격 변경','DEVICE_STATUS','N')");
    }
    DetectionRuleDTO rule() {
        DetectionRuleDTO rule = new DetectionRuleDTO();
        rule.setDetNo(1); rule.setDetRuleType("PRICE_CHANGED"); rule.setUseYn("Y");
        return rule;
    }
    PythonAnalysisResponse response() {
        return json.readValue("""
            {"success":true,"schemaVersion":2,"logType":"MIXED","totalLines":10,"parsedRecordCount":3,"unparsedLineCount":2,"parseFailureCount":0,"changeCount":1,"unknownCount":1,"failedOperationCount":0,"successCount":0,"successDeviceCount":0,"failureDeviceCount":0,"errorCount":0,
            "operations":[{"operationId":"SQL:8","category":"EXTERNAL_RESEND","operationType":"PAYMENT","deviceId":"00A01","resultStatus":"UNKNOWN","lineNo":8,"lineEnd":9,"rawLog":"request"}],
            "results":[{"logNo":2,"lineNo":4,"lineEnd":4,"deviceId":"00A01","slotCode":"TOYG01","ruleType":"PRICE_CHANGED","detectedValue":"100 -> 200","rawLog":"current","resultStatus":"CHANGE","category":"DEVICE_STATE","severity":"INFO","findingType":"CHANGE","previousLineNo":1,"previousRawLog":"previous","previousValue":"100","currentValue":"200","eventTime":"2026-09-17T10:00:00"}]}
            """, PythonAnalysisResponse.class);
    }
    @Test void persistsEvidenceAndUsesStartSnapshotEvenAfterRuleDisabled() {
        persistence.save(1,1,response(),List.of(rule()));
        AnalysisResultDTO saved = mapper.findDetectionResults(1).getFirst();
        assertEquals("00A01", saved.getDeviceId());
        assertEquals("TOYG01", saved.getSlotCode());
        assertEquals("CHANGE", saved.getResultStatus());
        assertEquals("INFO", saved.getSeverity());
        assertEquals(1, saved.getPreviousLineNo());
        assertEquals("previous", saved.getPreviousRawLog());
        assertEquals("200", saved.getCurrentValue());
        assertEquals("UNKNOWN", mapper.findOperations(1).getFirst().getResultStatus());
        InspectionDTO inspection = mapper.findInspection(1,1);
        assertEquals(1, inspection.getChangeCount());
        assertEquals(1, inspection.getUnknownCount());
        assertEquals(0, inspection.getAbnormalLogCount());
        assertEquals(2, inspection.getSchemaVersion());
        assertEquals("COMPLETED", inspection.getInsStatus());
        assertTrue(jdbc.queryForObject("SELECT RULE_SNAPSHOT FROM INSPECTIONS WHERE INS_NO=1",String.class).contains("PRICE_CHANGED"));
    }
    @Test void rollbackRemovesPartialOperationsAndResults() {
        PythonAnalysisResponse response = response();
        DetectionResultDTO invalid = new DetectionResultDTO(); invalid.setRuleType("UNREGISTERED");
        response.setResults(List.of(response.getResults().getFirst(),invalid));
        assertThrows(IllegalArgumentException.class, () -> persistence.save(1,1,response,List.of(rule())));
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM ANALYSIS_OPERATIONS",Integer.class));
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM DETECTION_RESULTS",Integer.class));
        assertEquals("UNKNOWN", jdbc.queryForObject("SELECT SOURCE_TYPE FROM LOG_FILES WHERE FILE_NO=1",String.class));
        mapper.failInspection(1);
        assertEquals("FAILED",mapper.findInspection(1,1).getInsStatus());
    }
    @Test void catalogRejectsUnsupportedRulesAndIncludesUnknown() {
        assertEquals("WARN",catalog.require("DB_TRANSFER_UNKNOWN").severity());
        assertThrows(IllegalArgumentException.class, () -> catalog.require("RUN_ARBITRARY_PATTERN"));
    }
    @Test void doesNotExposePartnerNamesInDisplay() {
        assertEquals("외부시스템 response APPROVAL=[비공개]",DisplaySanitizer.redact("JounSystem response APPROVAL=123456"));
        assertNull(DisplaySanitizer.redact(null));
    }

    @Autowired org.springframework.boot.web.server.context.WebServerApplicationContext serverContext;
    @org.springframework.boot.test.context.TestConfiguration
    static class TestWebConfig {
        @org.springframework.context.annotation.Bean TestLogin testLogin() { return new TestLogin(); }
    }
    @org.springframework.web.bind.annotation.RestController
    static class TestLogin {
        @org.springframework.web.bind.annotation.GetMapping("/test-session")
        String login(jakarta.servlet.http.HttpSession session) {
            UserDTO user = new UserDTO(); user.setUserNo(1); user.setUserId("test"); user.setRole("ADMIN");
            session.setAttribute("loginUser",user);
            return "ok";
        }
    }
    @Test void rendersResultHistoryAndRulesWithoutLosingUnknownOrChange() throws Exception {
        persistence.save(1,1,response(),List.of(rule()));
        var cookies = new java.net.CookieManager();
        var client = java.net.http.HttpClient.newBuilder().cookieHandler(cookies).build();
        String base = "http://localhost:" + serverContext.getWebServer().getPort();
        client.send(java.net.http.HttpRequest.newBuilder(java.net.URI.create(base+"/test-session")).GET().build(),java.net.http.HttpResponse.BodyHandlers.ofString());
        for (String path : List.of("/analysis/result/1", "/analysis/history", "/admin/rules", "/admin/rules/new", "/admin/inspections")) {
            var page = client.send(java.net.http.HttpRequest.newBuilder(java.net.URI.create(base+path)).GET().build(),java.net.http.HttpResponse.BodyHandlers.ofString());
            assertEquals(200,page.statusCode(),path+": "+page.body());
            if (path.contains("/result/")) {
                assertTrue(page.body().contains("결과 미확인"));
                assertTrue(page.body().contains("상태 변화"));
                assertTrue(page.body().contains("previous"));
                assertTrue(page.body().contains("00A01"));
            }
        }
    }

    @Test
    @org.junit.jupiter.api.condition.EnabledIfSystemProperty(named="logazac.private-samples", matches=".+")
    void privateSamplesTravelThroughPythonServiceAndDatabase() throws Exception {
        jdbc.update("DELETE FROM DETECTION_RULES");
        int ruleId = 1;
        for (RuleCatalog.Entry entry : catalog.entries()) {
            jdbc.update("INSERT INTO DETECTION_RULES(DET_NO,DET_RULE_TYPE,DET_PATTERN,DET_DESCRIPTION,LOG_TYPE,SEVERITY,USE_YN) VALUES(?,?,?,?,?,?,'Y')",
                ruleId++,entry.ruleType(),entry.pattern(),entry.description(),entry.logType(),entry.severity());
        }
        try (var samples = java.nio.file.Files.list(java.nio.file.Path.of(System.getProperty("logazac.private-samples")))) {
            int count = 0;
            for (var sample : samples.filter(path -> path.toString().endsWith(".txt") || path.toString().endsWith(".log")).sorted().toList()) {
                int id = analysis.analyzeAndSave(sample.toAbsolutePath().toString(), "private-sample-" + (++count) + ".log", 1);
                InspectionDTO inspection = mapper.findInspection(id,1);
                assertEquals("COMPLETED",inspection.getInsStatus());
                assertTrue(inspection.getParsedRecordCount() > 0);
                var operations = mapper.findOperations(id);
                assertEquals(operations.size(),inspection.getSuccessCount()+inspection.getFailedOperationCount()+inspection.getUnknownCount());
                assertEquals(inspection.getErrorCount(),mapper.findDetectionResults(id).stream().filter(r -> "ERROR".equals(r.getResultStatus())).count());
                if (inspection.getTotalLines()==740) assertEquals(350,inspection.getParsedRecordCount());
                if (inspection.getTotalLines()==868) assertEquals(294,inspection.getSuccessCount());
            }
            assertEquals(12,count,"Expected the reviewed 12-file private corpus");
        }
    }
}
