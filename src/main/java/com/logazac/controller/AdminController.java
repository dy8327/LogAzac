package com.logazac.controller;

import java.util.List;

import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.logazac.dto.AdminDashboardDTO;
import com.logazac.dto.UserDTO;
import com.logazac.service.AdminService;
import com.logazac.service.DetectionRuleService;
import com.logazac.dto.DailyStatisticsDTO;
import com.logazac.dto.RuleSummaryDTO;
import com.logazac.dto.DetectionRuleDTO;

@Controller
@RequestMapping("/admin")
public class AdminController {
    private final AdminService adminService;
    private final DetectionRuleService detectionRuleService;

    public AdminController(AdminService adminService, DetectionRuleService detectionRuleService) {
        this.adminService = adminService;
        this.detectionRuleService = detectionRuleService;
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

   @GetMapping("/rules")
    public String ruleList(HttpSession session, Model model) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/user/login";
        }
        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }
        model.addAttribute("rules", detectionRuleService.getAllRules());
        return "admin/ruleList";
    }

    @PostMapping("/rules/use")
    public String updateRuleUseYn(
        @RequestParam("detNo") int detNo,
        @RequestParam("useYn") String useYn,
        HttpSession session
    ) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/user/login";
        }
        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }
        if (!"Y".equals(useYn) && !"N".equals(useYn)) {
            return "redirect:/admin/rules";
        }
        detectionRuleService.updateUseYn(detNo, useYn);
        return "redirect:/admin/rules";
    }

    // 신규 규칙 등록
    @GetMapping("/rules/new")
    public String ruleForm(HttpSession session) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/user/login";
        }
        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }
        return "admin/ruleForm";
    }

    //규칙 등록 처리
    @PostMapping("/rules")
    public String insertRule(
        @RequestParam("detRuleType") String detRuleType,
        @RequestParam("detPattern") String detPattern,
        @RequestParam("detDescription") String detDescription,
        @RequestParam("useYn") String useYn,
        HttpSession session,
        RedirectAttributes redirectAttributes
    ) {
        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/";
        }

        if (!"Y".equals(useYn) && !"N".equals(useYn)) {
            return "redirect:/admin/rules";
        }

        DetectionRuleDTO rule = new DetectionRuleDTO();
        rule.setDetRuleType(detRuleType);
        rule.setDetPattern(detPattern);
        rule.setDetDescription(detDescription);
        rule.setUseYn(useYn);

        int result = detectionRuleService.insertRule(rule);

        if (result == 0) {
            redirectAttributes.addFlashAttribute("errorMessage", "이미 등록된 규칙입니다.");
            return "redirect:/admin/rules/new";
        }

        return "redirect:/admin/rules";
    }
}