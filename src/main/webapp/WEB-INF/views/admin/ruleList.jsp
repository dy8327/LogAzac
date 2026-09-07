<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>분석 규칙 관리 - LogAzac</title>
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
        <div class="page-title-wrap">
            <img src="${pageContext.request.contextPath}/resources/images/detection.png" alt="규칙 관리 카피바라" class="page-character">
            <div>
                <h1>분석 규칙 관리</h1>
                <p>로그 분석에 사용되는 분석 규칙을 관리합니다.</p>
            </div>
        </div>
        <div class="page-actions">
            <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
            <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/rules/new">규칙 등록</a>
        </div>
    </section>

    <section class="history-box">
        <div class="history-title">
            <h2>규칙 목록</h2>
            <span class="count">${rules.size()}</span>
        </div>

        <c:choose>
            <c:when test="${empty rules}">
                <div class="empty-message">등록된 분석 규칙이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table class="rule-table">
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>대상 로그</th>
                                <th>규칙 유형</th>
                                <th>심각도</th>
                                <th>상태</th>
                                <th>등록일</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rule" items="${rules}">
                                <tr class="rule-row" onclick="toggleRuleDetail(this)">
                                    <td>${rule.detNo}</td>
                                    <td class="rule-type">
                                        <c:choose>
                                            <c:when test="${rule.detRuleType eq 'MISSING_PRODUCT_NAME'}">상품명 누락</c:when>
                                            <c:when test="${rule.detRuleType eq 'CORRUPTED_DATA'}">깨진 데이터</c:when>
                                            <c:when test="${rule.detRuleType eq 'MISSING_SLOT'}">슬롯 누락</c:when>
                                            <c:when test="${rule.detRuleType eq 'PRICE_CHANGED'}">가격 변경</c:when>
                                            <c:when test="${rule.detRuleType eq 'PRODUCT_NAME_CHANGED'}">상품명 변경</c:when>
                                            <c:when test="${rule.detRuleType eq 'RETRANSMISSION_SUCCESS'}">재전송 정상</c:when>
                                            <c:when test="${rule.detRuleType eq 'DUPLICATE_RESPONSE'}">중복 응답</c:when>
                                            <c:when test="${rule.detRuleType eq 'RETRANSMISSION_FAILED'}">재전송 실패</c:when>
                                            <c:when test="${rule.detRuleType eq 'DB_TRANSFER_SUCCESS'}">DB 정상 처리</c:when>
                                            <c:when test="${rule.detRuleType eq 'CONSTRAINT_ERROR'}">DB 제약조건 오류</c:when>
                                            <c:when test="${rule.detRuleType eq 'BUSINESS_PROCESS_ERROR'}">업무 처리 오류</c:when>
                                            <c:when test="${rule.detRuleType eq 'DB_TRANSFER_FAILED'}">DB 처리 실패</c:when>
                                            <c:otherwise><c:out value="${rule.detRuleType}" /></c:otherwise>
                                        </c:choose>
                                        <span class="rule-toggle">▼</span>
                                    </td>
                                    <td class="rule-type">${rule.detRuleType}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${rule.severity eq 'INFO'}">정보</c:when>
                                            <c:when test="${rule.severity eq 'WARN'}">경고</c:when>
                                            <c:when test="${rule.severity eq 'ERROR'}">오류</c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="status ${rule.useYn eq 'Y' ? 'completed' : 'failed'}">
                                            ${rule.useYn eq 'Y' ? '사용' : '미사용'}
                                        </span>
                                    </td>
                                    <td>${rule.formattedRegDate}</td>
                                </tr>
                                <tr class="rule-detail-row">
                                    <td colspan="6">
                                        <div class="rule-detail">
                                            <div class="detail-item">
                                                <strong>패턴</strong>
                                                <span><c:out value="${rule.detPattern}" /></span>
                                            </div>
                                            <div class="detail-item">
                                                <strong>설명</strong>
                                                <span><c:out value="${rule.detDescription}" /></span>
                                            </div>
                                            <div class="detail-item">
                                                <strong>사용 여부</strong>
                                                <form action="${pageContext.request.contextPath}/admin/rules/use" method="post">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="detNo" value="${rule.detNo}">
                                                    <select name="useYn">
                                                        <option value="Y" ${rule.useYn eq 'Y' ? 'selected' : ''}>사용</option>
                                                        <option value="N" ${rule.useYn eq 'N' ? 'selected' : ''}>미사용</option>
                                                    </select>
                                                    <button class="action-btn" type="submit">적용</button>
                                                </form>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="../common/footer.jsp" />
<script>
function toggleRuleDetail(row) {
    const detailRow = row.nextElementSibling;
    const opened = detailRow.classList.toggle("open");
    row.classList.toggle("selected", opened);
    row.querySelector(".rule-toggle").textContent = opened ? "▲" : "▼";
}
</script>
</body>
</html>