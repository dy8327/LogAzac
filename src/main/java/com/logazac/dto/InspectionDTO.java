package com.logazac.dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class InspectionDTO {

    private int insNo;
    private int fileNo;
    private String insStatus;
    private int totalLines;
    private int errorCount;
    private String fileName;
    private String sourceType;
    private int abnormalLogCount;
    private LocalDateTime startDate;

    public int getInsNo() {
        return insNo;
    }

    public void setInsNo(int insNo) {
        this.insNo = insNo;
    }

    public int getFileNo() {
        return fileNo;
    }

    public void setFileNo(int fileNo) {
        this.fileNo = fileNo;
    }

    public String getInsStatus() {
        return insStatus;
    }

    public void setInsStatus(String insStatus) {
        this.insStatus = insStatus;
    }

    public int getTotalLines() {
        return totalLines;
    }

    public void setTotalLines(int totalLines) {
        this.totalLines = totalLines;
    }

    public int getErrorCount() {
        return errorCount;
    }

    public void setErrorCount(int errorCount) {
        this.errorCount = errorCount;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public int getAbnormalLogCount() {
        return abnormalLogCount;
    }

    public void setAbnormalLogCount(int abnormalLogCount) {
        this.abnormalLogCount = abnormalLogCount;
    }

    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public String getFormattedStartDate() {
        if (startDate == null) {
            return "";
        }

        return startDate.format(
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")
        );
    }
}