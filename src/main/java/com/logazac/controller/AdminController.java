package com.logazac.controller;

import java.util.List;

import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

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

    @GetMapping("/inspections")
    public String inspectionHistory(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }

        model.addAttribute("inspections", adminService.getInspectionHistory());

        return "admin/inspectionList";
    }

    @GetMapping("/users")
    public String userList(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }

        model.addAttribute("users", adminService.getAllUsers());

        return "admin/userList";
    }

    @PostMapping("/users/block")
    public String updateUserBlockStatus(
        @RequestParam("userNo") int userNo,
        @RequestParam("blockYn") String blockYn,
        HttpSession session
    ) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }

        if (loginUser.getUserNo() == userNo) {
            return "redirect:/admin/users";
        }

        if (!"Y".equals(blockYn) && !"N".equals(blockYn)) {
            return "redirect:/admin/users";
        }

        adminService.updateUserBlockStatus(userNo, blockYn);

        return "redirect:/admin/users";
    }

    @GetMapping("/files")
    public String fileList(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }

        model.addAttribute("logFiles", adminService.getAllLogFiles());

        return "admin/fileList";
    }
}