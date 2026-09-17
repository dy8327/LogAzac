package com.logazac.service;
import java.io.InputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.*;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;
import com.logazac.dto.PythonAnalysisResponse;
import tools.jackson.databind.json.JsonMapper;

@Service
public class PythonAnalyzerService {
    private final JsonMapper jsonMapper;
    @Value("${logazac.python-exe}") private String pythonExe;
    @Value("${logazac.analyzer-path}") private String analyzerPath;
    @Value("${logazac.analysis-timeout-seconds:120}") private long timeoutSeconds;
    public PythonAnalyzerService(JsonMapper jsonMapper) { this.jsonMapper = jsonMapper; }
    public PythonAnalysisResponse analyze(String filePath, String activeRuleTypes) throws Exception {
        ProcessBuilder builder = new ProcessBuilder(pythonExe, analyzerPath, filePath, activeRuleTypes);
        builder.environment().put("PYTHONIOENCODING", "UTF-8");
        builder.environment().put("PYTHONUTF8", "1");
        Process process = builder.start();
        ExecutorService readers = Executors.newFixedThreadPool(2);
        try {
            Future<String> stdout = readers.submit(() -> readOutput(process.getInputStream(), 64 * 1024 * 1024));
            Future<String> stderr = readers.submit(() -> readOutput(process.getErrorStream(), 1024 * 1024));
            if (!process.waitFor(timeoutSeconds, TimeUnit.SECONDS)) throw new IllegalStateException("로그 분석 제한 시간을 초과했습니다.");
            if (process.exitValue() != 0) throw new IllegalStateException("Python 분석 프로세스가 실패했습니다.");
            stderr.get(5, TimeUnit.SECONDS);
            return jsonMapper.readValue(stdout.get(5, TimeUnit.SECONDS), PythonAnalysisResponse.class);
        } finally {
            process.destroyForcibly();
            readers.shutdownNow();
        }
    }
    private static String readOutput(InputStream input, int limit) {
        try (input) {
            byte[] bytes = input.readNBytes(limit + 1);
            if (bytes.length > limit) throw new IOException("분석 출력 크기 제한을 초과했습니다.");
            return new String(bytes, StandardCharsets.UTF_8);
        } catch (IOException error) { throw new UncheckedIOException(error); }
    }
}
