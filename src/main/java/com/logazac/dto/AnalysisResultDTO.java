package com.logazac.dto;

public class AnalysisResultDTO {

    private int resultNo;
    private int insNo;
    private int lineNo;

    private String ruleType;
    private String ruleDescription;

    private String detectedValue;
    private String logContent;

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

    public int getLineNo() {
        return lineNo;
    }

    public void setLineNo(int lineNo) {
        this.lineNo = lineNo;
    }

    public String getRuleType() {
        return ruleType;
    }

    public void setRuleType(String ruleType) {
        this.ruleType = ruleType;
    }

    public String getRuleDescription() {
        return ruleDescription;
    }

    public void setRuleDescription(String ruleDescription) {
        this.ruleDescription = ruleDescription;
    }

    public String getDetectedValue() {
        return detectedValue;
    }

    public void setDetectedValue(String detectedValue) {
        this.detectedValue = detectedValue;
    }

    public String getLogContent() {
        return logContent;
    }

    public void setLogContent(String logContent) {
        this.logContent = logContent;
    }
}