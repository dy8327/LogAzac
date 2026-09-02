package com.logazac.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import com.logazac.dto.AdminDashboardDTO;
import com.logazac.dto.DailyStatisticsDTO;
import com.logazac.dto.RuleSummaryDTO;

@Mapper
public interface AdminMapper {
    AdminDashboardDTO findDashboardSummary();
    List<DailyStatisticsDTO> findDailyStatistics();
    List<RuleSummaryDTO> findRuleStatistics();
}