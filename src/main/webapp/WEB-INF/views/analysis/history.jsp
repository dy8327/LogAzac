<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>검사 이력 - LogAzac</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-history.css">
</head>
<body>

<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="history" />
</jsp:include>

<main class="page-wrap">
    <section class="page-header">
        <div class="page-title-wrap">
            <img src="${pageContext.request.contextPath}/resources/images/inspection.png" alt="검사이력 카피바라" class="page-character">
            <div>
                <h1>검사이력</h1>
                <p>내가 분석한 로그 검사 이력입니다.</p>
            </div>
        </div>
    </section>

    <section class="history-box">
        <div class="history-title">
            <h2>분석 기록</h2>
            <span class="count">${inspections.size()}건</span>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>검사번호</th>
                    <th>파일명</th>
                    <th>전체 로그</th>
                    <th>이상 로그</th>
                    <th>탐지 결과</th>
                    <th>상태</th>
                    <th>검사일</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty inspections}">
                        <tr>
                            <td colspan="9" class="empty-message">검사 이력이 없습니다.</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="inspection" items="${inspections}">
                            <tr>
                                <td>${inspection.insNo}</td>
                                <td class="file-name">${inspection.fileName}</td>
                                <td>${inspection.totalLines}</td>
                                <td class="abnormal-count">${inspection.abnormalLogCount}</td>
                                <td>${inspection.errorCount}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${inspection.insStatus eq 'COMPLETED'}">
                                            <span class="status completed">완료</span>
                                        </c:when>
                                        <c:when test="${inspection.insStatus eq 'FAILED'}">
                                            <span class="status failed">실패</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status processing">${inspection.insStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${inspection.formattedStartDate}</td>
                                <td>
                                    <a class="detail-btn" href="${pageContext.request.contextPath}/analysis/result/${inspection.insNo}">상세보기</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </section>
</main>

<jsp:include page="../common/footer.jsp" />

</body>
</html>