package com.logazac.dto;

public class DetectionSaveDTO {

    private int resultNo;
    private int insNo;
    private int detNo;
    private int lineNo;
    private String logContent;
    private String detectedValue;

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
}