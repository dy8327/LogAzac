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
    private String userId;
    private int abnormalLogCount;
    private LocalDateTime startDate;
    private int successCount;
    private int successDeviceCount;
    private int failureDeviceCount;

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

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public int getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(int successCount) {
        this.successCount = successCount;
    }

    public int getSuccessDeviceCount() {
        return successDeviceCount;
    }

    public void setSuccessDeviceCount(int successDeviceCount) {
        this.successDeviceCount = successDeviceCount;
    }

    public int getFailureDeviceCount() {
        return failureDeviceCount;
    }

    public void setFailureDeviceCount(int failureDeviceCount) {
        this.failureDeviceCount = failureDeviceCount;
    }

    private int schemaVersion;
    public int getSchemaVersion() { return schemaVersion; }
    public void setSchemaVersion(int value) { this.schemaVersion = value; }
    private int parsedRecordCount;
    public int getParsedRecordCount() { return parsedRecordCount; }
    public void setParsedRecordCount(int value) { this.parsedRecordCount = value; }
    private int unparsedLineCount;
    public int getUnparsedLineCount() { return unparsedLineCount; }
    public void setUnparsedLineCount(int value) { this.unparsedLineCount = value; }
    private int parseFailureCount;
    public int getParseFailureCount() { return parseFailureCount; }
    public void setParseFailureCount(int value) { this.parseFailureCount = value; }
    private int changeCount;
    public int getChangeCount() { return changeCount; }
    public void setChangeCount(int value) { this.changeCount = value; }
    private int unknownCount;
    public int getUnknownCount() { return unknownCount; }
    public void setUnknownCount(int value) { this.unknownCount = value; }
    private int failedOperationCount;
    public int getFailedOperationCount() { return failedOperationCount; }
    public void setFailedOperationCount(int value) { this.failedOperationCount = value; }

    public String getDisplayFileName() { return com.logazac.service.DisplaySanitizer.redact(fileName); }
}
