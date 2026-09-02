package com.logazac.dto;

public class AdminDashboardDTO {
    private int userCount;
    private int fileCount;
    private int inspectionCount;
    private long totalLineCount;
    private int abnormalLogCount;
    private int detectionCount;

    public int getUserCount() {
        return userCount;
    }

    public void setUserCount(int userCount) {
        this.userCount = userCount;
    }

    public int getFileCount() {
        return fileCount;
    }

    public void setFileCount(int fileCount) {
        this.fileCount = fileCount;
    }

    public int getInspectionCount() {
        return inspectionCount;
    }

    public void setInspectionCount(int inspectionCount) {
        this.inspectionCount = inspectionCount;
    }

    public long getTotalLineCount() {
        return totalLineCount;
    }

    public void setTotalLineCount(long totalLineCount) {
        this.totalLineCount = totalLineCount;
    }

    public int getAbnormalLogCount() {
        return abnormalLogCount;
    }

    public void setAbnormalLogCount(int abnormalLogCount) {
        this.abnormalLogCount = abnormalLogCount;
    }

    public int getDetectionCount() {
        return detectionCount;
    }

    public void setDetectionCount(int detectionCount) {
        this.detectionCount = detectionCount;
    }
}