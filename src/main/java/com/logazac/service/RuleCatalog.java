package com.logazac.service;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import tools.jackson.databind.json.JsonMapper;
@Component
public class RuleCatalog {
    public record Entry(String ruleType, String logType, String severity, String pattern, String description) {}
    private final List<Entry> entries;
    public RuleCatalog(JsonMapper mapper) throws IOException {
        try (var input = new ClassPathResource("analysis-rules.json").getInputStream()) {
            entries = List.copyOf(Arrays.asList(mapper.readValue(input, Entry[].class)));
        }
    }
    public List<Entry> entries() { return entries; }
    public Entry require(String code) {
        return entries.stream().filter(entry -> entry.ruleType().equals(code)).findFirst()
            .orElseThrow(() -> new IllegalArgumentException("지원하지 않는 분석 규칙입니다."));
    }
}
