package com.logazac.service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import org.springframework.stereotype.Service;

import com.logazac.dto.DetectionResultDTO;
import com.logazac.dto.DetectionSaveDTO;
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

    public AnalysisService(
        AnalysisMapper analysisMapper,
        DetectionRuleMapper detectionRuleMapper,
        PythonAnalyzerService pythonAnalyzerService
    ) {
        this.analysisMapper = analysisMapper;
        this.detectionRuleMapper = detectionRuleMapper;
        this.pythonAnalyzerService = pythonAnalyzerService;
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
                System.out.println("활성 분석 규칙: " + activeRuleTypes);

            PythonAnalysisResponse response = pythonAnalyzerService.analyze(filePath, activeRuleTypes);
            System.out.println("Python 분석 결과: type=" + response.getLogType() + ", success=" + response.getSuccessCount() + ", error=" + response.getErrorCount() + ", results=" + response.getResults().size());

            if (!response.isSuccess()) {
                throw new IllegalArgumentException(response.getMessage());
            }

            if (response.getLogType() == null || response.getLogType().isBlank()) {
                throw new IllegalArgumentException("로그 유형을 판별할 수 없습니다.");
            }

            int sourceTypeUpdateResult = analysisMapper.updateLogFileSourceType(
                logFile.getFileNo(),
                response.getLogType()
            );

            if (sourceTypeUpdateResult == 0) {
                throw new IllegalStateException("로그 유형 저장에 실패했습니다.");
            }

            /* 4. 탐지 결과 저장 */
            for (
                DetectionResultDTO result : response.getResults()
            ) {

                Integer detNo = detectionRuleMapper.findDetNoByRuleType(result.getRuleType());

                if (detNo == null) {
                    throw new RuntimeException("등록되지 않은 탐지 규칙: " + result.getRuleType());
                }

                DetectionSaveDTO save = new DetectionSaveDTO();

                save.setInsNo(inspection.getInsNo());
                save.setDetNo(detNo);
                save.setLineNo(result.getLineNo());
                save.setLogContent(result.getRawLog());
                save.setDetectedValue(result.getDetectedValue());
                save.setDeviceId(result.getDeviceId());
                save.setSlotCode(result.getSlotCode());
                save.setResultStatus(
                    result.getResultStatus() == null || result.getResultStatus().isBlank()
                        ? "ERROR"
                        : result.getResultStatus()
                );

                analysisMapper.insertDetectionResult(save);
            }

            /* 5. 검사 완료 */
            analysisMapper.completeInspection(
                inspection.getInsNo(),
                response.getTotalLines(),
                response.getSuccessCount(),
                response.getSuccessDeviceCount(),
                response.getFailureDeviceCount(),
                response.getErrorCount()
            );

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

        return analysisMapper.findDetectionResults(insNo);
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
}