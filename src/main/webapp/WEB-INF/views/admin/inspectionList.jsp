<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 검사이력</title>
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
            <img src="${pageContext.request.contextPath}/resources/images/inspection.png" alt="검사이력 카피바라" class="page-character">
            <div>
                <h1>전체 검사이력</h1>
                <p>전체 사용자의 로그 검사 이력입니다.</p>
            </div>
        </div>
        <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
    </section>

    <section class="history-box">
        <div class="history-title">
            <h2>검사 목록</h2>
            <span class="count">${inspections.size()}</span>
        </div>

        <c:choose>
            <c:when test="${empty inspections}">
                <div class="empty-message">등록된 검사이력이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>검사번호</th>
                                <th>사용자</th>
                                <th>파일명</th>
                                <th>로그종류</th>
                                <th>검사일시</th>
                                <th>전체 로그</th>
                                <th>이상 로그</th>
                                <th>상태</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="inspection" items="${inspections}">
                                <tr>
                                    <td>${inspection.insNo}</td>
                                    <td>${inspection.userId}</td>
                                    <td class="file-name"><c:out value="${inspection.fileName}" /></td>
                                    <td class="source-type">
                                        <c:choose>
                                            <c:when test="${inspection.sourceType eq 'VENDING'}">자판기 로그</c:when>
                                            <c:when test="${inspection.sourceType eq 'PAYMENT'}">결제기 로그</c:when>
                                            <c:otherwise>${inspection.sourceType}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${inspection.formattedStartDate}</td>
                                    <td>${inspection.totalLines}</td>
                                    <td class="abnormal-count">${inspection.abnormalLogCount}</td>
                                    <td>
                                        <span class="status ${inspection.insStatus eq 'COMPLETED' ? 'completed' : inspection.insStatus eq 'FAILED' ? 'failed' : 'processing'}">
                                            ${inspection.insStatus}
                                        </span>
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