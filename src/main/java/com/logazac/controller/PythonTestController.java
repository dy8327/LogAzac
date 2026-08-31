package com.logazac.controller;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.logazac.dto.PythonAnalysisResponse;
import com.logazac.mapper.DetectionRuleMapper;
import com.logazac.service.PythonAnalyzerService;
import com.logazac.service.AnalysisService;

@RestController
public class PythonTestController {

    private final PythonAnalyzerService pythonAnalyzerService;
    private final DetectionRuleMapper detectionRuleMapper;
    private final AnalysisService analysisService;

    public PythonTestController(
        PythonAnalyzerService pythonAnalyzerService,
        DetectionRuleMapper detectionRuleMapper,
        AnalysisService analysisService
    ) {
        this.pythonAnalyzerService = pythonAnalyzerService;
        this.detectionRuleMapper = detectionRuleMapper;
        this.analysisService = analysisService;
    }

    @GetMapping("/test/python")
    public PythonAnalysisResponse testPython() throws Exception {

        String filePath =
            "D:/doyoung/LogAzac/02021070138상품명및금액변경건.txt";

        return pythonAnalyzerService.analyze(filePath);
    }

    @GetMapping("/test/db")
    public Integer testDb() {

        return detectionRuleMapper.findDetNoByRuleType(
            "PRICE_CHANGED"
        );
    }

    @GetMapping("/test/save")
    public Map<String, Object> testSave() throws Exception {

        String filePath =
            "D:/doyoung/LogAzac/02021070138상품명및금액변경건.txt";

        int insNo = analysisService.analyzeAndSave(
            filePath,
            1,
            "VENDING"
        );

        return Map.of(
            "success", true,
            "insNo", insNo
        );
    }
}