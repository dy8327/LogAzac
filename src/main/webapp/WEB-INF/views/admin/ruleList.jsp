<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>이상 판단 규칙 관리 - LogAzac</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-history.css">
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
                <h1>이상 판단 규칙 관리</h1>
                <p>로그 분석에 사용되는 이상 판단 규칙을 관리합니다.</p>
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
                <div class="empty-message">등록된 이상 판단 규칙이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>규칙유형</th>
                                <th>패턴</th>
                                <th>설명</th>
                                <th>사용여부</th>
                                <th>등록일</th>
                                <th>관리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rule" items="${rules}">
                                <tr>
                                    <td>${rule.detNo}</td>
                                    <td>${rule.detRuleType}</td>
                                    <td>${rule.detPattern}</td>
                                    <td>${rule.detDescription}</td>
                                    <td>
                                        <span class="status ${rule.useYn eq 'Y' ? 'completed' : 'failed'}">
                                            ${rule.useYn eq 'Y' ? '사용' : '미사용'}
                                        </span>
                                    </td>
                                    <td>${rule.formattedRegDate}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${rule.useYn eq 'Y'}">
                                                <form class="action-form" action="${pageContext.request.contextPath}/admin/rules/use" method="post">
                                                    <input type="hidden" name="detNo" value="${rule.detNo}">
                                                    <input type="hidden" name="useYn" value="N">
                                                    <button class="action-btn" type="submit">미사용</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form class="action-form" action="${pageContext.request.contextPath}/admin/rules/use" method="post">
                                                    <input type="hidden" name="detNo" value="${rule.detNo}">
                                                    <input type="hidden" name="useYn" value="Y">
                                                    <button class="action-btn unblock" type="submit">사용</button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
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
</body>
</html>