package com.logazac.dto;

public class DetectionSaveDTO {

    private int resultNo;
    private int insNo;
    private int detNo;
    private int lineNo;
    private String logContent;
    private String detectedValue;
    private String deviceId;
    private String slotCode;
    private String resultStatus;

    public int getResultNo() {
        return resultNo;
    }

    public void setResultNo(int resultNo) {
        this.resultNo = resultNo;
    }

    public int getInsNo() {
        return insNo;
    }

    public void setInsNo(int insNo) {
        this.insNo = insNo;
    }

    public int getDetNo() {
        return detNo;
    }

    public void setDetNo(int detNo) {
        this.detNo = detNo;
    }

    public int getLineNo() {
        return lineNo;
    }

    public void setLineNo(int lineNo) {
        this.lineNo = lineNo;
    }

    public String getLogContent() {
        return logContent;
    }

    public void setLogContent(String logContent) {
        this.logContent = logContent;
    }

    public String getDetectedValue() {
        return detectedValue;
    }

    public void setDetectedValue(String detectedValue) {
        this.detectedValue = detectedValue;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public String getSlotCode() {
        return slotCode;
    }

    public void setSlotCode(String slotCode) {
        this.slotCode = slotCode;
    }

    public String getResultStatus() {
        return resultStatus;
    }

    public void setResultStatus(String resultStatus) {
        this.resultStatus = resultStatus;
    }

    private Integer lineEnd;
    public Integer getLineEnd() { return lineEnd; }
    public void setLineEnd(Integer value) { this.lineEnd = value; }
    private String category;
    public String getCategory() { return category; }
    public void setCategory(String value) { this.category = value; }
    private String severity;
    public String getSeverity() { return severity; }
    public void setSeverity(String value) { this.severity = value; }
    private String findingType;
    public String getFindingType() { return findingType; }
    public void setFindingType(String value) { this.findingType = value; }
    private String operationId;
    public String getOperationId() { return operationId; }
    public void setOperationId(String value) { this.operationId = value; }
    private String operationType;
    public String getOperationType() { return operationType; }
    public void setOperationType(String value) { this.operationType = value; }
    private String businessDate;
    public String getBusinessDate() { return businessDate; }
    public void setBusinessDate(String value) { this.businessDate = value; }
    private String transactionKey;
    public String getTransactionKey() { return transactionKey; }
    public void setTransactionKey(String value) { this.transactionKey = value; }
    private String reasonCode;
    public String getReasonCode() { return reasonCode; }
    public void setReasonCode(String value) { this.reasonCode = value; }
    private Integer previousLineNo;
    public Integer getPreviousLineNo() { return previousLineNo; }
    public void setPreviousLineNo(Integer value) { this.previousLineNo = value; }
    private String previousRawLog;
    public String getPreviousRawLog() { return previousRawLog; }
    public void setPreviousRawLog(String value) { this.previousRawLog = value; }
    private String previousValue;
    public String getPreviousValue() { return previousValue; }
    public void setPreviousValue(String value) { this.previousValue = value; }
    private String currentValue;
    public String getCurrentValue() { return currentValue; }
    public void setCurrentValue(String value) { this.currentValue = value; }
    private String eventTime;
    public String getEventTime() { return eventTime; }
    public void setEventTime(String value) { this.eventTime = value; }

}
