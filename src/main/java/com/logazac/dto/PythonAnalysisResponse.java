package com.logazac.dto;

import java.util.List;

public class PythonAnalysisResponse {

    private boolean success;
    private int errorCount;
    private String message;
    private List<DetectionResultDTO> results;
    private int totalLines;
    private String logType;
    private int successDeviceCount;
    private int successCount;
    private int failureDeviceCount;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public int getErrorCount() {
        return errorCount;
    }

    public void setErrorCount(int errorCount) {
        this.errorCount = errorCount;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<DetectionResultDTO> getResults() {
        return results;
    }

    public void setResults(List<DetectionResultDTO> results) {
        this.results = results;
    }

    public int getTotalLines() {
    return totalLines;
    }

    public void setTotalLines(int totalLines) {
        this.totalLines = totalLines;
    }

    public String getLogType() {
        return logType;
    }

    public void setLogType(String logType) {
        this.logType = logType;
    }

    public int getSuccessDeviceCount() {
        return successDeviceCount;
    }

    public void setSuccessDeviceCount(int successDeviceCount) {
        this.successDeviceCount = successDeviceCount;
    }

    public int getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(int successCount) {
        this.successCount = successCount;
    }

    public int getFailureDeviceCount() {
        return failureDeviceCount;
    }

    public void setFailureDeviceCount(int failureDeviceCount) {
        this.failureDeviceCount = failureDeviceCount;
    }
}