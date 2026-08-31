package com.logazac.dto;

import java.util.List;

public class PythonAnalysisResponse {

    private boolean success;
    private int errorCount;
    private String message;
    private List<DetectionResultDTO> results;
    private int totalLines;

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
}