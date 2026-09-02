package com.logazac.dto;

public class DailyStatisticsDTO {
    private String statDate;
    private int inspectionCount;
    private int abnormalLogCount;

    public String getStatDate() {
        return statDate;
    }

    public void setStatDate(String statDate) {
        this.statDate = statDate;
    }

    public int getInspectionCount() {
        return inspectionCount;
    }

    public void setInspectionCount(int inspectionCount) {
        this.inspectionCount = inspectionCount;
    }

    public int getAbnormalLogCount() {
        return abnormalLogCount;
    }

    public void setAbnormalLogCount(int abnormalLogCount) {
        this.abnormalLogCount = abnormalLogCount;
    }
}