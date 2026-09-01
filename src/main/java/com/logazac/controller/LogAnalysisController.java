package com.logazac.controller;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.List;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;

import com.logazac.service.AnalysisService;
import com.logazac.dto.AnalysisResultDTO;
import com.logazac.dto.InspectionDTO;
import com.logazac.dto.RuleSummaryDTO;
import com.logazac.dto.UserDTO;

@Controller
public class LogAnalysisController {

    private final AnalysisService analysisService;

    @Value("${logazac.upload-dir}")
    private String uploadDir;

    public LogAnalysisController(AnalysisService analysisService) {
        this.analysisService = analysisService;
    }


    /*
     * 로그 업로드 화면
     */
   @GetMapping("/analysis")
    public String uploadForm(HttpSession session) {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        return "analysis/upload";
    }

    /*
     * 로그 업로드 + 분석
     */
    @PostMapping("/analysis/upload")
    public String uploadAndAnalyze(
        @RequestParam("logFile") MultipartFile logFile,
        @RequestParam("sourceType") String sourceType,
        HttpSession session
    ) throws Exception {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        if (logFile.isEmpty()) {
            throw new IllegalArgumentException("업로드할 로그 파일이 없습니다.");
        }

        if (!"VENDING".equals(sourceType) && !"PAYMENT".equals(sourceType)) {
            throw new IllegalArgumentException("지원하지 않는 로그 종류입니다.");
        }

        String originalFileName =
            Paths.get(logFile.getOriginalFilename())
                .getFileName()
                .toString();

        String savedFileName = UUID.randomUUID() + "_" + originalFileName;

        Path uploadPath = Paths.get(uploadDir);
        Files.createDirectories(uploadPath);

        Path savedPath = uploadPath.resolve(savedFileName);
        logFile.transferTo(savedPath);

        int insNo = analysisService.analyzeAndSave(
            savedPath.toString(),
            originalFileName,
            loginUser.getUserNo(),
            sourceType
        );

        return "redirect:/analysis/result/" + insNo;
    }

    @GetMapping("/analysis/result/{insNo}")
    public String analysisResult(
        @PathVariable("insNo") int insNo,
        HttpSession session,
        Model model
    ) {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        InspectionDTO inspection = analysisService.getInspection(insNo, loginUser.getUserNo());

        if (inspection == null) {
            return "redirect:/analysis/history";
        }

        List<AnalysisResultDTO> results = analysisService.getDetectionResults(insNo);

        List<RuleSummaryDTO> topRules = analysisService.getTopDetectionRules(insNo);

        model.addAttribute("inspection", inspection);
        model.addAttribute("results", results);
        model.addAttribute("topRules", topRules);

        return "analysis/result";
    }

    @GetMapping("/analysis/history")
    public String history(HttpSession session, Model model) {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        List<InspectionDTO> inspections = analysisService.getInspectionHistory(loginUser.getUserNo());

        model.addAttribute("inspections", inspections);

        return "analysis/history";
    }
}