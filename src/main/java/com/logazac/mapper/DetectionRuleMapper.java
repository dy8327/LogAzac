package com.logazac.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.logazac.dto.DetectionRuleDTO;

@Mapper
public interface DetectionRuleMapper {

    Integer findDetNoByRuleType(@Param("ruleType") String ruleType);

    List<DetectionRuleDTO> findAllRules();
    List<DetectionRuleDTO> findActiveRules();
    
    int updateUseYn(@Param("detNo") int detNo, @Param("useYn") String useYn);
    int insertRule(DetectionRuleDTO rule);
}