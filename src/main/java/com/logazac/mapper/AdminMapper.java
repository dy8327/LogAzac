package com.logazac.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.logazac.dto.AdminDashboardDTO;
import com.logazac.dto.DailyStatisticsDTO;
import com.logazac.dto.RuleSummaryDTO;
import com.logazac.dto.InspectionDTO;
import com.logazac.dto.UserDTO;
import com.logazac.dto.LogFileDTO;

@Mapper
public interface AdminMapper {
    AdminDashboardDTO findDashboardSummary();
    List<DailyStatisticsDTO> findDailyStatistics();
    List<RuleSummaryDTO> findRuleStatistics();
    List<InspectionDTO> findInspectionHistory();
    List<UserDTO> findAllUsers();
    List<LogFileDTO> findAllLogFiles();
    int updateUserBlockStatus(@Param("userNo") int userNo, @Param("blockYn") String blockYn);
}