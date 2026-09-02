package com.logazac.dto;

import java.time.LocalDateTime;

public class DetectionRuleDTO {
    private int detNo;
    private String detRuleType;
    private String detPattern;
    private String detDescription;
    private String useYn;
    private LocalDateTime regDate;

    public int getDetNo() {
        return detNo;
    }

    public void setDetNo(int detNo) {
        this.detNo = detNo;
    }

    public String getDetRuleType() {
        return detRuleType;
    }

    public void setDetRuleType(String detRuleType) {
        this.detRuleType = detRuleType;
    }

    public String getDetPattern() {
        return detPattern;
    }

    public void setDetPattern(String detPattern) {
        this.detPattern = detPattern;
    }

    public String getDetDescription() {
        return detDescription;
    }

    public void setDetDescription(String detDescription) {
        this.detDescription = detDescription;
    }

    public String getUseYn() {
        return useYn;
    }

    public void setUseYn(String useYn) {
        this.useYn = useYn;
    }

    public LocalDateTime getRegDate() {
        return regDate;
    }

    public void setRegDate(LocalDateTime regDate) {
        this.regDate = regDate;
    }

    public String getFormattedRegDate() {
        if (regDate == null) {
            return "";
        }
        return regDate.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }
}