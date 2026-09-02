package com.logazac.controller;

import java.util.List;

import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.logazac.dto.AdminDashboardDTO;
import com.logazac.dto.UserDTO;
import com.logazac.service.AdminService;
import com.logazac.dto.DailyStatisticsDTO;
import com.logazac.dto.RuleSummaryDTO;

@Controller
@RequestMapping("/admin")
public class AdminController {
    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping({"", "/", "/dashboard"})
    public String dashboard(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }

        AdminDashboardDTO summary = adminService.getDashboardSummary();
        List<DailyStatisticsDTO> dailyStatistics = adminService.getDailyStatistics();
        List<RuleSummaryDTO> ruleStatistics = adminService.getRuleStatistics();

        model.addAttribute("summary", summary);
        model.addAttribute("dailyStatistics", dailyStatistics);
        model.addAttribute("ruleStatistics", ruleStatistics);
        return "admin/dashboard";
    }
}