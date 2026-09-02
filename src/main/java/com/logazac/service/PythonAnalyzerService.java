package com.logazac.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import org.springframework.stereotype.Service;

import com.logazac.dto.PythonAnalysisResponse;

import tools.jackson.databind.json.JsonMapper;

@Service
public class PythonAnalyzerService {

    private final JsonMapper jsonMapper;

    public PythonAnalyzerService(JsonMapper jsonMapper) {
        this.jsonMapper = jsonMapper;
    }

    public PythonAnalysisResponse analyze(String filePath, String activeRuleTypes) throws Exception {

        String pythonExe =
            "C:/Users/Administrator/AppData/Local/Python/pythoncore-3.14-64/python.exe";

        String analyzerPath =
            "D:/doyoung/LogAzac/logazac/python/analyzer.py";

        // 경로 확인
        System.out.println("Python 실행파일: " + pythonExe);
        System.out.println("Analyzer 경로: " + analyzerPath);
        System.out.println("Analyzer 존재: " + Files.exists(Path.of(analyzerPath)));
        System.out.println("분석파일 경로: " + filePath);
        System.out.println("분석파일 존재: " + Files.exists(Path.of(filePath)));

        ProcessBuilder processBuilder = new ProcessBuilder(
            pythonExe,
            analyzerPath,
            filePath,
            activeRuleTypes
        );

        // Python 출력 인코딩 UTF-8 고정
        processBuilder.environment().put("PYTHONIOENCODING", "UTF-8");
        processBuilder.environment().put("PYTHONUTF8", "1");
        processBuilder.redirectErrorStream(true);

        Process process = processBuilder.start();

        StringBuilder output = new StringBuilder();

        try (
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8)
            )
        ) {
            String line;

            while ((line = reader.readLine()) != null) {
                output.append(line);
            }
        }

        int exitCode = process.waitFor();

        if (exitCode != 0) {
            throw new RuntimeException("Python 분석 실패. exitCode="
                    + exitCode + ", output=" + output);
        }

        return jsonMapper.readValue(output.toString(),PythonAnalysisResponse.class);
    }
}