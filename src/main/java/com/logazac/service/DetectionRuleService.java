package com.logazac.service;

import java.util.List;
import org.springframework.stereotype.Service;
import com.logazac.dto.DetectionRuleDTO;
import com.logazac.mapper.DetectionRuleMapper;

@Service
public class DetectionRuleService {
    private final DetectionRuleMapper detectionRuleMapper;
    private final RuleCatalog catalog;

    public DetectionRuleService(DetectionRuleMapper detectionRuleMapper, RuleCatalog catalog) {
        this.detectionRuleMapper = detectionRuleMapper;
        this.catalog = catalog;
    }

    public List<DetectionRuleDTO> getAllRules() {
        return detectionRuleMapper.findAllRules();
    }

    public int updateUseYn(int detNo, String useYn) {
        return detectionRuleMapper.updateUseYn(detNo, useYn);
    }

    public int insertRule(DetectionRuleDTO rule) {
        RuleCatalog.Entry entry = catalog.require(rule.getDetRuleType());
        if (!"Y".equals(rule.getUseYn()) && !"N".equals(rule.getUseYn())) throw new IllegalArgumentException("사용 여부가 올바르지 않습니다.");
        rule.setLogType(entry.logType());
        rule.setSeverity(entry.severity());
        rule.setDetPattern(entry.pattern());
        rule.setDetDescription(entry.description());
        Integer count = detectionRuleMapper.countByRuleType(rule.getDetRuleType());

        if (count != null && count > 0) {
            return 0;
        }

        return detectionRuleMapper.insertRule(rule);
    }
}
