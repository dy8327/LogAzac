<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원관리 - LogAzac</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            <img src="${pageContext.request.contextPath}/resources/images/member.png" alt="회원관리 카피바라" class="page-character">
            <div>
                <h1>회원관리</h1>
                <p>가입된 회원의 계정 상태를 확인합니다.</p>
            </div>
        </div>
        <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/dashboard">대시보드</a>
    </section>

    <section class="history-box">
        <div class="history-title">
            <h2>회원 목록</h2>
            <span class="count">${users.size()}</span>
        </div>

        <c:choose>
            <c:when test="${empty users}">
                <div class="empty-message">등록된 회원이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>회원번호</th>
                                <th>아이디</th>
                                <th>이메일</th>
                                <th>권한</th>
                                <th>가입일</th>
                                <th>차단여부</th>
                                <th>관리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="user" items="${users}">
                                <tr>
                                    <td>${user.userNo}</td>
                                    <td>${user.userId}</td>
                                    <td>${user.userEmail}</td>
                                    <td>${user.role}</td>
                                    <td>${user.regDate}</td>
                                    <td>
                                        <span class="status ${user.blockYn eq 'Y' ? 'failed' : 'completed'}">
                                            ${user.blockYn eq 'Y' ? '차단' : '정상'}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${loginUser.userNo eq user.userNo}">
                                                <span>-</span>
                                            </c:when>
                                            <c:when test="${user.blockYn eq 'Y'}">
                                                <form class="action-form" action="${pageContext.request.contextPath}/admin/users/block" method="post">
                                                    <input type="hidden" name="userNo" value="${user.userNo}">
                                                    <input type="hidden" name="blockYn" value="N">
                                                    <button class="action-btn unblock" type="submit">해제</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form class="action-form" action="${pageContext.request.contextPath}/admin/users/block" method="post">
                                                    <input type="hidden" name="userNo" value="${user.userNo}">
                                                    <input type="hidden" name="blockYn" value="Y">
                                                    <button class="action-btn" type="submit">차단</button>
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