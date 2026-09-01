package com.logazac.service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import org.springframework.stereotype.Service;

import com.logazac.dto.DetectionResultDTO;
import com.logazac.dto.DetectionSaveDTO;
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
        int userNo,
        String sourceType
    ) throws Exception {

        Path path = Path.of(filePath);

        /* 1. 업로드 파일 DB 저장 */
        LogFileDTO logFile = new LogFileDTO();

        logFile.setFileName(originalFileName);
        logFile.setFileSize(Files.size(path));
        logFile.setUserNo(userNo);
        logFile.setSourceType(sourceType);
        logFile.setFilePath(filePath);

        analysisMapper.insertLogFile(logFile);

        /* 2. 검사 생성 */
        InspectionDTO inspection = new InspectionDTO();

        inspection.setFileNo(logFile.getFileNo());

        analysisMapper.insertInspection(inspection);

        try {

            /* 3. Python 로그 분석 */
            PythonAnalysisResponse response = pythonAnalyzerService.analyze(filePath);

            if (!response.isSuccess()) {
                throw new RuntimeException("Python 분석 실패: " + response.getMessage());
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

                analysisMapper.insertDetectionResult(save);
            }

            /* 5. 검사 완료 */
            analysisMapper.completeInspection(
                inspection.getInsNo(),
                response.getTotalLines(),
                response.getErrorCount()
            );

            return inspection.getInsNo();

        } catch (Exception e) {

            analysisMapper.failInspection(inspection.getInsNo());

            throw e;
        }
    }

    public InspectionDTO getInspection(int insNo) {

        return analysisMapper.findInspection(insNo);
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
}