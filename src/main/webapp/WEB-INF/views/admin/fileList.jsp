<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그파일 관리 - LogAzac</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-history.css">
</head>
<body>
<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="admin" />
</jsp:include>

<main class="page-wrap">
    <section class="page-header">
        <div>
            <h1>로그파일 관리</h1>
            <p>전체 사용자가 업로드한 로그파일 현황입니다.</p>
        </div>
        <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
    </section>

    <section class="history-box">
        <div class="history-title">
            <h2>파일 목록</h2>
            <span class="count">${logFiles.size()}</span>
        </div>

        <c:choose>
            <c:when test="${empty logFiles}">
                <div class="empty-message">등록된 로그파일이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>파일번호</th>
                                <th>사용자</th>
                                <th>파일명</th>
                                <th>로그종류</th>
                                <th>파일크기</th>
                                <th>등록일</th>
                                <th>삭제상태</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="file" items="${logFiles}">
                                <tr>
                                    <td>${file.fileNo}</td>
                                    <td>${file.userId}</td>
                                    <td class="file-name">${file.fileName}</td>
                                    <td class="source-type">
                                        <c:choose>
                                            <c:when test="${file.sourceType eq 'VENDING'}">자판기 로그</c:when>
                                            <c:when test="${file.sourceType eq 'PAYMENT'}">결제기 로그</c:when>
                                            <c:otherwise>${file.sourceType}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${file.fileSize} Byte</td>
                                    <td>${file.formattedFileRegdate}</td>
                                    <td>
                                        <span class="status ${file.deletedYn eq 'Y' ? 'failed' : 'completed'}">
                                            ${file.deletedYn eq 'Y' ? '삭제됨' : '보관중'}
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