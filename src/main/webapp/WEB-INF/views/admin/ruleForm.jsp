<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>이상 판단 규칙 등록 - LogAzac</title>
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
            <h1>이상 판단 규칙 등록</h1>
            <p>로그 분석에 사용할 새 규칙을 등록합니다.</p>
        </div>
        <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/rules">목록</a>
    </section>

    <section class="history-box rule-form">
    <c:if test="${not empty errorMessage}">
        <div class="error-message">${errorMessage}</div>
    </c:if>
        <form action="${pageContext.request.contextPath}/admin/rules" method="post">
            <div class="form-group">
                <label for="detRuleType">규칙 유형</label>
                <select id="detRuleType" name="detRuleType" onchange="setRuleInfo()" required>
                    <option value="">규칙 선택</option>
                    <option value="MISSING_PRODUCT_NAME">상품명 누락</option>
                    <option value="CORRUPTED_DATA">깨진 데이터</option>
                    <option value="MISSING_SLOT">슬롯 누락</option>
                    <option value="PRICE_CHANGED">가격 변경</option>
                    <option value="PRODUCT_NAME_CHANGED">상품명 변경</option>
                    <option value="DUPLICATE_ERROR">무결성 제약조건 위배</option>
                    <option value="NULL_ERROR">필수값 NULL 오류</option>
                    <option value="CLOSED_BUSINESS_ERROR">일마감 처리 오류</option>
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
function setRuleInfo() {
    const type = document.getElementById("detRuleType").value;
    const pattern = document.getElementById("detPattern");
    const description = document.getElementById("detDescription");

    const rules = {
        MISSING_PRODUCT_NAME: ["EMPTY_PRODUCT_NAME", "슬롯의 상품명이 누락된 경우"],
        CORRUPTED_DATA: ["INVALID_CHARACTER", "로그 또는 상품명에 비정상 문자가 포함된 경우"],
        MISSING_SLOT: ["PREVIOUS_SLOT_COMPARE", "이전 로그에 존재하던 슬롯이 현재 로그에서 누락된 경우"],
        PRICE_CHANGED: ["PREVIOUS_PRICE_COMPARE", "동일 장비 동일 슬롯의 가격이 이전 값과 달라진 경우"],
        PRODUCT_NAME_CHANGED: ["PREVIOUS_NAME_COMPARE", "동일 장비 동일 슬롯의 상품명이 변경된 경우"],
        DUPLICATE_ERROR: ["ORA-00001", "무결성 제약조건 위배 오류 탐지"],
        NULL_ERROR: ["ORA-01400", "필수값 NULL 삽입 오류 탐지"],
        CLOSED_BUSINESS_ERROR: ["ORA-20001", "일마감처리된 영업장 오류 탐지"]
    };

    if (rules[type]) {
        pattern.value = rules[type][0];
        description.value = rules[type][1];
    } else {
        pattern.value = "";
        description.value = "";
    }
}
</script>
</body>
</html>