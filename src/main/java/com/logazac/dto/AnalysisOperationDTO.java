package com.logazac.dto;
public class AnalysisOperationDTO {

    private int insNo;
    public int getInsNo() { return insNo; }
    public void setInsNo(int value) { this.insNo = value; }
    private String operationId;
    public String getOperationId() { return operationId; }
    public void setOperationId(String value) { this.operationId = value; }
    private String category;
    public String getCategory() { return category; }
    public void setCategory(String value) { this.category = value; }
    private String operationType;
    public String getOperationType() { return operationType; }
    public void setOperationType(String value) { this.operationType = value; }
    private String deviceId;
    public String getDeviceId() { return deviceId; }
    public void setDeviceId(String value) { this.deviceId = value; }
    private String businessDate;
    public String getBusinessDate() { return businessDate; }
    public void setBusinessDate(String value) { this.businessDate = value; }
    private String transactionKey;
    public String getTransactionKey() { return transactionKey; }
    public void setTransactionKey(String value) { this.transactionKey = value; }
    private String resultStatus;
    public String getResultStatus() { return resultStatus; }
    public void setResultStatus(String value) { this.resultStatus = value; }
    private String reasonCode;
    public String getReasonCode() { return reasonCode; }
    public void setReasonCode(String value) { this.reasonCode = value; }
    private int lineNo;
    public int getLineNo() { return lineNo; }
    public void setLineNo(int value) { this.lineNo = value; }
    private int lineEnd;
    public int getLineEnd() { return lineEnd; }
    public void setLineEnd(int value) { this.lineEnd = value; }
    private String rawLog;
    public String getRawLog() { return rawLog; }
    public void setRawLog(String value) { this.rawLog = value; }
    public String getOperationLabel() {
        if (operationType == null) return "처리 단계 미확인";
        return switch (operationType) {
            case "PAYMENT" -> "결제 전송";
            case "PRODUCT_SALES" -> "상품 매출 전송";
            case "PAYMENT_METHOD_TOTAL" -> "결제수단 집계 전송";
            case "SALES_REQUEST" -> "매출 데이터 요청";
            case "UNLINKED_RESPONSE" -> "요청 연결 미확인 응답";
            default -> "처리 단계 미확인";
        };
    }
}
