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

    private List<AnalysisOperationDTO> operations;
    public List<AnalysisOperationDTO> getOperations() { return operations; }
    public void setOperations(List<AnalysisOperationDTO> value) { this.operations = value; }


}
