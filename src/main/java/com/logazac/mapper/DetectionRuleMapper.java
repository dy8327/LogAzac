package com.logazac.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface DetectionRuleMapper {

    Integer findDetNoByRuleType(
        @Param("ruleType") String ruleType
    );
}