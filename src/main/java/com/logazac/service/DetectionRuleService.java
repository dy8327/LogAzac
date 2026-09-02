package com.logazac.service;

import java.util.List;
import org.springframework.stereotype.Service;
import com.logazac.dto.DetectionRuleDTO;
import com.logazac.mapper.DetectionRuleMapper;

@Service
public class DetectionRuleService {
    private final DetectionRuleMapper detectionRuleMapper;

    public DetectionRuleService(DetectionRuleMapper detectionRuleMapper) {
        this.detectionRuleMapper = detectionRuleMapper;
    }

    public List<DetectionRuleDTO> getAllRules() {
        return detectionRuleMapper.findAllRules();
    }

    public int updateUseYn(int detNo, String useYn) {
        return detectionRuleMapper.updateUseYn(detNo, useYn);
    }

    public int insertRule(DetectionRuleDTO rule) {
        return detectionRuleMapper.insertRule(rule);
    }
}