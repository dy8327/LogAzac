<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>분석 규칙 등록 - LogAzac</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-history.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin-rule.css">
</head>
<body>
<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="admin" />
</jsp:include>

<main class="page-wrap">
    <section class="page-header">
        <div>
            <h1>분석 규칙 등록</h1>
            <p>로그 분석에 사용할 새 규칙을 등록합니다.</p>
        </div>
        <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/rules">목록</a>
    </section>

    <section class="history-box rule-form">
    <c:if test="${not empty errorMessage}">
        <div class="error-message">${errorMessage}</div>
    </c:if>
        <form action="${pageContext.request.contextPath}/admin/rules" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="form-group">
                <label for="logType">대상 로그 유형</label>
                <select id="logType" name="logType" onchange="updateRuleOptions()" required>
                    <option value="">로그 유형 선택</option>
                    <option value="DEVICE_STATUS">장비 상태 로그</option>
                    <option value="EXTERNAL_RETRANSMISSION">외부 시스템 재전송</option>
                    <option value="EXTERNAL_INTEGRATION">외부 연동 DB 처리</option>
                </select>
            </div>
            <div class="form-group">
                <label for="detRuleType">규칙 유형</label>
                <select id="detRuleType" name="detRuleType" onchange="setRuleInfo()" required>
                    <option value="">먼저 로그 유형을 선택하세요</option>
                </select>
            </div>
            <div class="form-group">
                <label for="detPattern">패턴</label>
                <input type="text" id="detPattern" name="detPattern" readonly required>
            </div>
            <div class="form-group">
                <label for="detDescription">설명</label>
                <textarea id="detDescription" name="detDescription" readonly required></textarea>
            </div>
            <div class="form-group">
                <label for="severity">심각도</label>
                <input type="text" id="severityLabel" readonly>
                <input type="hidden" id="severity" name="severity">
            </div>
            <div class="form-group">
                <label for="useYn">사용 여부</label>
                <select id="useYn" name="useYn">
                    <option value="Y">사용</option>
                    <option value="N">미사용</option>
                </select>
            </div>
            <div class="form-actions">
                <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/rules">취소</a>
                <button class="action-btn" type="submit">등록</button>
            </div>
        </form>
    </section>
</main>

<jsp:include page="../common/footer.jsp" />

<script>
const ruleDefinitions = {
    DEVICE_STATUS: {
        MISSING_PRODUCT_NAME: ["EMPTY_PRODUCT_NAME", "슬롯의 상품명이 누락된 경우", "ERROR"],
        CORRUPTED_DATA: ["INVALID_CHARACTER", "로그 또는 상품명에 비정상 문자가 포함된 경우", "ERROR"],
        MISSING_SLOT: ["PREVIOUS_SLOT_COMPARE", "이전 로그에 존재하던 슬롯이 현재 로그에서 누락된 경우", "ERROR"],
        PRICE_CHANGED: ["PREVIOUS_PRICE_COMPARE", "동일 장비 동일 슬롯의 가격이 이전 값과 달라진 경우", "ERROR"],
        PRODUCT_NAME_CHANGED: ["PREVIOUS_NAME_COMPARE", "동일 장비 동일 슬롯의 상품명이 변경된 경우", "ERROR"]
    },
    EXTERNAL_RETRANSMISSION: {
        RETRANSMISSION_SUCCESS: ["RESPONSE_CODE_1", "외부 시스템 재전송이 정상 처리된 경우", "INFO"],
        DUPLICATE_RESPONSE: ["KEY_DUPLICATE_ERROR", "외부 시스템 재전송에서 중복 응답이 발생한 경우", "ERROR"],
        RETRANSMISSION_FAILED: ["NON_SUCCESS_RESPONSE", "외부 시스템 재전송이 정상 완료되지 않은 경우", "ERROR"]
    },
    EXTERNAL_INTEGRATION: {
        DB_TRANSFER_SUCCESS: ["COMPLETED_WITHOUT_ERROR", "DB 재전송 작업이 오류 없이 정상 진행된 경우", "INFO"],
        CONSTRAINT_ERROR: ["ORA-00001|ORA-01400", "DB 재전송 중 중복 데이터 또는 필수값 누락 오류가 발생한 경우", "ERROR"],
        BUSINESS_PROCESS_ERROR: ["ORA-20001", "DB 재전송 중 업무 처리 조건에 의해 거부된 경우", "ERROR"],
        DB_TRANSFER_FAILED: ["DB_TRANSFER_ERROR", "DB 재전송 작업이 정상 완료되지 않은 경우", "ERROR"]
    }
};

const ruleNames = {
    MISSING_PRODUCT_NAME: "상품명 누락",
    CORRUPTED_DATA: "깨진 데이터",
    MISSING_SLOT: "슬롯 누락",
    PRICE_CHANGED: "가격 변경",
    PRODUCT_NAME_CHANGED: "상품명 변경",
    RETRANSMISSION_SUCCESS: "재전송 정상 처리",
    DUPLICATE_RESPONSE: "중복 응답",
    RETRANSMISSION_FAILED: "재전송 실패",
    DB_TRANSFER_SUCCESS: "DB 정상 처리",
    CONSTRAINT_ERROR: "DB 제약조건 오류",
    BUSINESS_PROCESS_ERROR: "업무 처리 오류",
    DB_TRANSFER_FAILED: "DB 처리 실패"
};

function updateRuleOptions() {
    const logType = document.getElementById("logType").value;
    const ruleSelect = document.getElementById("detRuleType");
    ruleSelect.innerHTML = '<option value="">규칙 선택</option>';

    if (!ruleDefinitions[logType]) {
        setRuleInfo();
        return;
    }

    Object.keys(ruleDefinitions[logType]).forEach(function(ruleType) {
        const option = document.createElement("option");
        option.value = ruleType;
        option.textContent = ruleNames[ruleType];
        ruleSelect.appendChild(option);
    });

    setRuleInfo();
}

function setRuleInfo() {
    const logType = document.getElementById("logType").value;
    const ruleType = document.getElementById("detRuleType").value;
    const pattern = document.getElementById("detPattern");
    const description = document.getElementById("detDescription");
    const severity = document.getElementById("severity");

    const rule = ruleDefinitions[logType]?.[ruleType];

    if (rule) {
        pattern.value = rule[0];
        description.value = rule[1];
        severity.value = rule[2];
        severityLabel.value =
            rule[2] === "INFO" ? "정보" :
            rule[2] === "WARN" ? "경고" : "오류";
    } else {
        severity.value = "";
        severityLabel.value = "";
    }
}
</script>
</body>
</html>