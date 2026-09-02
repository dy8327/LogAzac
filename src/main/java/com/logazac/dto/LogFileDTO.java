package com.logazac.dto;

import java.time.LocalDateTime;

public class LogFileDTO {

    private int fileNo;
    private String fileName;
    private long fileSize;
    private int userNo;
    private String sourceType;
    private String filePath;
    private String userId;
    private String deletedYn;
    private LocalDateTime fileRegdate;

    public int getFileNo() {
        return fileNo;
    }

    public void setFileNo(int fileNo) {
        this.fileNo = fileNo;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public long getFileSize() {
        return fileSize;
    }

    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    public int getUserNo() {
        return userNo;
    }

    public void setUserNo(int userNo) {
        this.userNo = userNo;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getDeletedYn() {
        return deletedYn;
    }

    public void setDeletedYn(String deletedYn) {
        this.deletedYn = deletedYn;
    }

    public LocalDateTime getFileRegdate() {
        return fileRegdate;
    }

    public void setFileRegdate(LocalDateTime fileRegdate) {
        this.fileRegdate = fileRegdate;
    }

    public String getFormattedFileRegdate() {
        if (fileRegdate == null) {
            return "";
        }
        return fileRegdate.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }
}