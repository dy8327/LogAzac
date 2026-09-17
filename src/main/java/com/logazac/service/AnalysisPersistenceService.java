package com.logazac.service;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.logazac.dto.*;
import com.logazac.mapper.AnalysisMapper;
import tools.jackson.databind.json.JsonMapper;

@Service
public class AnalysisPersistenceService {
    private final AnalysisMapper mapper;
    private final JsonMapper jsonMapper;
    public AnalysisPersistenceService(AnalysisMapper mapper, JsonMapper jsonMapper) {
        this.mapper = mapper;
        this.jsonMapper = jsonMapper;
    }
    @Transactional(rollbackFor = Exception.class)
    public void save(int fileNo, int insNo, PythonAnalysisResponse response, List<DetectionRuleDTO> rules) {
        if (response.getSchemaVersion() != 2 || response.getResults() == null || response.getOperations() == null) {
            throw new IllegalArgumentException("분석기 결과 형식이 일치하지 않습니다.");
        }
        long successes = response.getOperations().stream().filter(o -> "SUCCESS".equals(o.getResultStatus())).count();
        long failures = response.getOperations().stream().filter(o -> "ERROR".equals(o.getResultStatus())).count();
        long unknown = response.getOperations().stream().filter(o -> "UNKNOWN".equals(o.getResultStatus())).count();
        if (successes != response.getSuccessCount() || failures != response.getFailedOperationCount() || unknown != response.getUnknownCount()
                || successes + failures + unknown != response.getOperations().size()) {
            throw new IllegalArgumentException("작업 결과 집계가 일치하지 않습니다.");
        }
        Map<String, DetectionRuleDTO> snapshot = rules.stream().collect(Collectors.toMap(DetectionRuleDTO::getDetRuleType, Function.identity()));
        if (mapper.updateLogFileSourceType(fileNo, response.getLogType()) != 1) {
            throw new IllegalStateException("로그 유형 저장에 실패했습니다.");
        }
        for (AnalysisOperationDTO operation : response.getOperations()) {
            operation.setInsNo(insNo);
            mapper.insertOperation(operation);
        }
        for (DetectionResultDTO result : response.getResults()) {
            DetectionRuleDTO rule = snapshot.get(result.getRuleType());
            if (rule == null) throw new IllegalArgumentException("분석 시작 시 활성화되지 않은 규칙입니다.");
            DetectionSaveDTO save = new DetectionSaveDTO();
            save.setInsNo(insNo);
            save.setDetNo(rule.getDetNo());
            save.setLineNo(result.getLineNo());
            save.setLogContent(result.getRawLog());
            save.setDetectedValue(result.getDetectedValue());
            save.setDeviceId(result.getDeviceId());
            save.setSlotCode(result.getSlotCode());
            save.setResultStatus(result.getResultStatus());
            save.setLineEnd(result.getLineEnd());
            save.setCategory(result.getCategory());
            save.setSeverity(result.getSeverity());
            save.setFindingType(result.getFindingType());
            save.setOperationId(result.getOperationId());
            save.setOperationType(result.getOperationType());
            save.setBusinessDate(result.getBusinessDate());
            save.setTransactionKey(result.getTransactionKey());
            save.setReasonCode(result.getReasonCode());
            save.setPreviousLineNo(result.getPreviousLineNo());
            save.setPreviousRawLog(result.getPreviousRawLog());
            save.setPreviousValue(result.getPreviousValue());
            save.setCurrentValue(result.getCurrentValue());
            save.setEventTime(result.getEventTime());

            mapper.insertDetectionResult(save);
        }
        if (mapper.completeInspection(insNo, response, jsonMapper.writeValueAsString(rules)) != 1) {
            throw new IllegalStateException("분석 결과 저장에 실패했습니다.");
        }
    }
}
