package com.logazac.service;

import java.util.List;

import org.springframework.stereotype.Service;
import com.logazac.dto.AdminDashboardDTO;
import com.logazac.mapper.AdminMapper;
import com.logazac.dto.DailyStatisticsDTO;
import com.logazac.dto.RuleSummaryDTO;
import com.logazac.dto.InspectionDTO;

@Service
public class AdminService {
    private final AdminMapper adminMapper;

    public AdminService(AdminMapper adminMapper) {
        this.adminMapper = adminMapper;
    }

    public AdminDashboardDTO getDashboardSummary() {
        return adminMapper.findDashboardSummary();
    }

    public List<DailyStatisticsDTO> getDailyStatistics() {
        return adminMapper.findDailyStatistics();
    }

    public List<RuleSummaryDTO> getRuleStatistics() {
        return adminMapper.findRuleStatistics();
    }

    public List<InspectionDTO> getInspectionHistory() {
        return adminMapper.findInspectionHistory();
    }
}