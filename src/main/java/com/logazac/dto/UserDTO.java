package com.logazac.dto;

import java.time.LocalDateTime;

public class UserDTO {

    private int userNo;
    private String userId;
    private String userPw;
    private String userEmail;
    private String role;
    private LocalDateTime regDate;
    private String blockYn;

    public int getUserNo() {
        return userNo;
    }

    public void setUserNo(int userNo) {
        this.userNo = userNo;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserPw() {
        return userPw;
    }

    public void setUserPw(String userPw) {
        this.userPw = userPw;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public LocalDateTime getRegDate() {
        return regDate;
    }

    public void setRegDate(LocalDateTime regDate) {
        this.regDate = regDate;
    }

    public String getBlockYn() {
        return blockYn;
    }

    public void setBlockYn(String blockYn) {
        this.blockYn = blockYn;
    }
}