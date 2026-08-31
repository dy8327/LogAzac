package com.logazac.controller;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.List;

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
    public String uploadForm() {

        return "analysis/upload";
    }

    /*
     * 로그 업로드 + 분석
     */
    @PostMapping("/analysis/upload")
    public String uploadAndAnalyze(
        @RequestParam("logFile") MultipartFile logFile,
        @RequestParam("sourceType") String sourceType
    ) throws Exception {

        /* 파일 확인 */
        if (logFile.isEmpty()) {
            throw new IllegalArgumentException("업로드할 로그 파일이 없습니다.");
        }

        /* 로그 종류 확인 */
        if (
            !"VENDING".equals(sourceType)
            && !"PAYMENT".equals(sourceType)
        ) {
            throw new IllegalArgumentException("지원하지 않는 로그 종류입니다.");
        }

        /*
         * 원본 파일명
         *
         * 디렉터리 경로가 포함되어 들어오는 것을 방지하기 위해
         * getFileName()으로 파일명만 추출
         */
        String originalFileName =
            Paths.get(logFile.getOriginalFilename())
            .getFileName()
            .toString();

        /*
         * 같은 이름의 파일 덮어쓰기 방지
         */
        String savedFileName = UUID.randomUUID() + "_" + originalFileName;

        /*
         * 업로드 폴더 생성
         */
        Path uploadPath = Paths.get(uploadDir);
        Files.createDirectories(uploadPath);

        /*
         * 실제 저장 경로
         */
        Path savedPath = uploadPath.resolve(savedFileName);

        /*
         * 파일 저장
         */
        logFile.transferTo(savedPath);

        /*
         * 현재는 로그인 기능 연결 전이므로
         * 테스트 회원 USER_NO = 1 사용
         */
        int userNo = 1;

        /*
         * Python 분석 + DB 저장
         *
         * 반환값 = INSPECTIONS.INS_NO
         */
        int insNo = analysisService.analyzeAndSave(
                savedPath.toString(),
                userNo,
                sourceType
            );

        /*
         * 분석 결과 상세 페이지로 이동
         */
        return "redirect:/analysis/result/" + insNo;
    }

    @GetMapping("/analysis/result/{insNo}")
    public String analysisResult(
        @PathVariable("insNo") int insNo,
        Model model
    ) {

        InspectionDTO inspection =
            analysisService.getInspection(insNo);

        List<AnalysisResultDTO> results =
            analysisService.getDetectionResults(insNo);

        model.addAttribute(
            "inspection",
            inspection
        );

        model.addAttribute(
            "results",
            results
        );

        return "analysis/result";
    }
}