package com.logazac.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.logazac.dto.DetectionSaveDTO;
import com.logazac.dto.InspectionDTO;
import com.logazac.dto.LogFileDTO;
import com.logazac.dto.AnalysisResultDTO;
import com.logazac.dto.RuleSummaryDTO;

@Mapper
public interface AnalysisMapper {

    // 로그 파일 저장
    int insertLogFile(LogFileDTO logFile);

    // 검사 생성
    int insertInspection(InspectionDTO inspection);

    // 이상 탐지 결과 저장
    int insertDetectionResult(DetectionSaveDTO result);

    // 검사 완료
    int completeInspection(
        @Param("insNo") int insNo,
        @Param("totalLines") int totalLines,
        @Param("errorCount") int errorCount
    );

    // 검사 실패
    int failInspection(@Param("insNo") int insNo);

    InspectionDTO findInspection(@Param("insNo") int insNo);

    List<AnalysisResultDTO> findDetectionResults(@Param("insNo") int insNo);

    List<RuleSummaryDTO> findTopDetectionRules(@Param("insNo") int insNo);

    List<InspectionDTO> findInspectionHistory(@Param("userNo") int userNo);
}