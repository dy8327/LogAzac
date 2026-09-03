package com.logazac.controller;

import java.io.IOException;
import java.io.InputStream;
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
     * 업로드 허용 확장자
     */
    private static final List<String> ALLOWED_EXTENSIONS = List.of(".txt", ".log");

    /*
     * 텍스트/바이너리 판별을 위해 앞부분 몇 바이트만 확인
     */
    private static final int SNIFF_SIZE = 8192;

    /*
     * 로그 업로드 + 분석
     */
    @PostMapping("/analysis/upload")
    public String uploadAndAnalyze(
        @RequestParam("logFile") MultipartFile logFile,
        @RequestParam("sourceType") String sourceType,
        HttpSession session,
        Model model
    ) throws Exception {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        try {

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

            if (!hasAllowedExtension(originalFileName)) {
                throw new IllegalArgumentException("TXT 또는 LOG 파일만 업로드할 수 있습니다.");
            }

            if (!looksLikePlainText(logFile)) {
                throw new IllegalArgumentException("텍스트 형식의 로그 파일이 아닌 것 같습니다. 파일 내용을 확인해 주세요.");
            }

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

        } catch (IllegalArgumentException e) {

            model.addAttribute("errorMessage", e.getMessage());

            return "analysis/upload";
        }
    }

    /*
     * 파일명 확장자가 허용 목록(.txt, .log)에 속하는지 확인
     */
    private boolean hasAllowedExtension(String fileName) {

        String lower = fileName.toLowerCase();

        return ALLOWED_EXTENSIONS.stream().anyMatch(lower::endsWith);
    }

    /*
     * 파일 앞부분을 샘플링해 텍스트 파일인지 간단히 판별.
     * - NULL 바이트가 하나라도 있으면 바이너리로 간주
     * - 제어문자(탭/개행/캐리지리턴 제외) 비율이 5% 이상이면 바이너리로 간주
     * 확장자를 속여도(예: 실행 파일에 .log 확장자) 걸러내기 위한 2차 방어선
     */
    private boolean looksLikePlainText(MultipartFile file) throws IOException {

        byte[] sample;

        try (InputStream in = file.getInputStream()) {
            sample = in.readNBytes(SNIFF_SIZE);
        }

        if (sample.length == 0) {
            return true;
        }

        int suspiciousCount = 0;

        for (byte b : sample) {

            int unsigned = b & 0xFF;

            if (unsigned == 0) {
                return false;
            }

            boolean isControlChar =
                unsigned < 0x20
                    && unsigned != '\t'
                    && unsigned != '\n'
                    && unsigned != '\r';

            if (isControlChar) {
                suspiciousCount++;
            }
        }

        double suspiciousRatio = (double) suspiciousCount / sample.length;

        return suspiciousRatio < 0.05;
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