package com.logazac.service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import org.springframework.stereotype.Service;

import com.logazac.dto.DetectionRuleDTO;
import com.logazac.dto.InspectionDTO;
import com.logazac.dto.LogFileDTO;
import com.logazac.dto.PythonAnalysisResponse;
import com.logazac.mapper.AnalysisMapper;
import com.logazac.mapper.DetectionRuleMapper;
import com.logazac.dto.AnalysisResultDTO;
import com.logazac.dto.RuleSummaryDTO;

@Service
public class AnalysisService {

    private final AnalysisMapper analysisMapper;
    private final DetectionRuleMapper detectionRuleMapper;
    private final PythonAnalyzerService pythonAnalyzerService;
    private final AnalysisPersistenceService persistenceService;

    public AnalysisService(
        AnalysisMapper analysisMapper,
        DetectionRuleMapper detectionRuleMapper,
        PythonAnalyzerService pythonAnalyzerService,
        AnalysisPersistenceService persistenceService
    ) {
        this.analysisMapper = analysisMapper;
        this.detectionRuleMapper = detectionRuleMapper;
        this.pythonAnalyzerService = pythonAnalyzerService;
        this.persistenceService = persistenceService;
    }

    public int analyzeAndSave(
        String filePath,
        String originalFileName,
        int userNo
    ) throws Exception {

        Path path = Path.of(filePath);

        /* 1. 업로드 파일 DB 저장 */
        LogFileDTO logFile = new LogFileDTO();

        logFile.setFileName(originalFileName);
        logFile.setFileSize(Files.size(path));
        logFile.setUserNo(userNo);
        logFile.setSourceType("UNKNOWN");
        logFile.setFilePath(filePath);
        
        analysisMapper.insertLogFile(logFile);

        /* 2. 검사 생성 */
        InspectionDTO inspection = new InspectionDTO();

        inspection.setFileNo(logFile.getFileNo());

        analysisMapper.insertInspection(inspection);

        try {

            /* 3. Python 로그 분석 */
            List<DetectionRuleDTO> activeRules = detectionRuleMapper.findActiveRules();
            String activeRuleTypes = activeRules.stream()
                .map(DetectionRuleDTO::getDetRuleType)
                .collect(java.util.stream.Collectors.joining(","));

            PythonAnalysisResponse response = pythonAnalyzerService.analyze(filePath, activeRuleTypes);

            if (!response.isSuccess()) {
                throw new IllegalArgumentException(response.getMessage());
            }

            if (response.getLogType() == null || response.getLogType().isBlank()) {
                throw new IllegalArgumentException("로그 유형을 판별할 수 없습니다.");
            }

            persistenceService.save(logFile.getFileNo(), inspection.getInsNo(), response, activeRules);

            return inspection.getInsNo();

        } catch (Exception e) {

            analysisMapper.failInspection(inspection.getInsNo());

            throw e;
        }
    }

    public InspectionDTO getInspection(int insNo, int userNo) {

        return analysisMapper.findInspection(insNo, userNo);
    }

    public List<AnalysisResultDTO> getDetectionResults(int insNo) {

        List<AnalysisResultDTO> results = analysisMapper.findDetectionResults(insNo);
        results.forEach(result -> {
            result.setLogContent(DisplaySanitizer.redact(result.getLogContent()));
            result.setPreviousRawLog(DisplaySanitizer.redact(result.getPreviousRawLog()));
            result.setDetectedValue(DisplaySanitizer.redact(result.getDetectedValue()));
            result.setPreviousValue(DisplaySanitizer.redact(result.getPreviousValue()));
            result.setCurrentValue(DisplaySanitizer.redact(result.getCurrentValue()));
            result.setRuleDescription(DisplaySanitizer.redact(result.getRuleDescription()));
        });
        return results;
    }

    public List<RuleSummaryDTO> getTopDetectionRules(
        int insNo
    ) {
        return analysisMapper.findTopDetectionRules(insNo);
    }

    public List<InspectionDTO> getInspectionHistory(int userNo) {
        return analysisMapper.findInspectionHistory(userNo);
    }

    public List<LogFileDTO> getUserLogFiles(int userNo) {
        return analysisMapper.findUserLogFiles(userNo);
    }

    public void deleteUserLogFile(int fileNo, int userNo) throws Exception {

        LogFileDTO logFile = analysisMapper.findUserLogFile(fileNo, userNo);

        if (logFile == null) {
            throw new IllegalArgumentException("삭제할 파일을 찾을 수 없습니다.");
        }

        Path filePath = Path.of(logFile.getFilePath());

        Files.deleteIfExists(filePath);

        int result = analysisMapper.markLogFileDeleted(fileNo, userNo);

        if (result == 0) {
            throw new IllegalStateException("파일 삭제 처리에 실패했습니다.");
        }
    }
    public List<com.logazac.dto.AnalysisOperationDTO> getOperations(int insNo) {
        List<com.logazac.dto.AnalysisOperationDTO> operations = analysisMapper.findOperations(insNo);
        operations.forEach(operation -> operation.setRawLog(DisplaySanitizer.redact(operation.getRawLog())));
        return operations;
    }
}
