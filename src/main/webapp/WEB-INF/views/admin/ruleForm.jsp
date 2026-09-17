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
        <div class="error-message"><c:out value="${errorMessage}" /></div>
    </c:if>
        <form action="${pageContext.request.contextPath}/admin/rules" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="form-group">
                <label for="logType">대상 로그 유형</label>
                <select id="logType" name="logType" onchange="updateRuleOptions()" required>
                    <option value="">로그 유형 선택</option>
                    <option value="DEVICE_STATUS">장비 상태 로그</option>
                    <option value="EXTERNAL_RETRANSMISSION">외부 연동 데이터 로그</option>
                    <option value="EXTERNAL_INTEGRATION">외부 시스템 재전송 로그</option>
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
  "DEVICE_STATUS": {
    "MISSING_PRODUCT_NAME": [
      "EMPTY_PRODUCT_NAME",
      "상품명 누락",
      "WARN"
    ],
    "CORRUPTED_DATA": [
      "INVALID_CHARACTER",
      "비정상 문자",
      "WARN"
    ],
    "MISSING_SLOT": [
      "PREVIOUS_SLOT_COMPARE",
      "슬롯 누락 후보",
      "WARN"
    ],
    "PRICE_CHANGED": [
      "PREVIOUS_PRICE_COMPARE",
      "가격 변경",
      "INFO"
    ],
    "PRODUCT_NAME_CHANGED": [
      "PREVIOUS_NAME_COMPARE",
      "상품명 변경",
      "INFO"
    ],
    "STOCK_CHANGED": [
      "PREVIOUS_STOCK_COMPARE",
      "재고 변화",
      "INFO"
    ],
    "SLOT_RESTORED": [
      "PREVIOUS_MISSING_SLOT",
      "슬롯 재등장",
      "INFO"
    ]
  },
  "EXTERNAL_INTEGRATION": {
    "DB_TRANSFER_SUCCESS": [
      "EXPLICIT_SQL_SUCCESS",
      "외부 시스템 재전송 성공",
      "INFO"
    ],
    "CONSTRAINT_ERROR": [
      "ORA-00001|ORA-01400",
      "중복 또는 필수값 NULL 오류",
      "ERROR"
    ],
    "BUSINESS_PROCESS_ERROR": [
      "ORA-20001_AND_CLOSED",
      "일마감 처리 오류",
      "ERROR"
    ],
    "DB_TRANSFER_FAILED": [
      "EXPLICIT_SQL_FAILURE",
      "외부 시스템 재전송 실패",
      "ERROR"
    ],
    "DB_TRANSFER_UNKNOWN": [
      "NO_CONFIRMED_RESULT",
      "외부 시스템 재전송 결과 미확인",
      "WARN"
    ]
  },
  "EXTERNAL_RETRANSMISSION": {
    "RETRANSMISSION_SUCCESS": [
      "RESPONSE_CODE_1",
      "외부 연동 정상 응답",
      "INFO"
    ],
    "DUPLICATE_RESPONSE": [
      "KEY_DUPLICATE_ERROR",
      "외부 연동 중복 응답",
      "ERROR"
    ],
    "RETRANSMISSION_FAILED": [
      "NON_SUCCESS_RESPONSE",
      "외부 연동 실패 응답",
      "ERROR"
    ],
    "RETRANSMISSION_UNKNOWN": [
      "NO_CONFIRMED_RESPONSE",
      "외부 연동 응답 미확인",
      "WARN"
    ]
  }
};
const ruleNames = {
  "MISSING_PRODUCT_NAME": "상품명 누락",
  "CORRUPTED_DATA": "비정상 문자",
  "MISSING_SLOT": "슬롯 누락 후보",
  "PRICE_CHANGED": "가격 변경",
  "PRODUCT_NAME_CHANGED": "상품명 변경",
  "STOCK_CHANGED": "재고 변화",
  "SLOT_RESTORED": "슬롯 재등장",
  "DB_TRANSFER_SUCCESS": "외부 시스템 재전송 성공",
  "CONSTRAINT_ERROR": "중복 또는 필수값 NULL 오류",
  "BUSINESS_PROCESS_ERROR": "일마감 처리 오류",
  "DB_TRANSFER_FAILED": "외부 시스템 재전송 실패",
  "DB_TRANSFER_UNKNOWN": "외부 시스템 재전송 결과 미확인",
  "RETRANSMISSION_SUCCESS": "외부 연동 정상 응답",
  "DUPLICATE_RESPONSE": "외부 연동 중복 응답",
  "RETRANSMISSION_FAILED": "외부 연동 실패 응답",
  "RETRANSMISSION_UNKNOWN": "외부 연동 응답 미확인"
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
