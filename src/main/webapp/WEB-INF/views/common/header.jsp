<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<header class="site-header">

    <div class="site-header-inner">

        <a class="site-logo"
           href="${pageContext.request.contextPath}/">
            Log<span>Azac</span>
        </a>

        <div class="site-header-menu">

            <nav class="site-nav">

                <a class="${param.activeMenu eq 'home' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/">
                    홈
                </a>

                <a class="${param.activeMenu eq 'analysis' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/analysis">
                    로그 분석
                </a>

                <a class="${param.activeMenu eq 'history' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/analysis/history">
                    검사 이력
                </a>

                <c:if test="${sessionScope.loginUser.role eq 'ADMIN'}">
                    <a href="${pageContext.request.contextPath}/admin">
                        관리자
                    </a>
                </c:if>

            </nav>

            <div class="site-user-menu">

                <c:choose>

                    <c:when test="${not empty sessionScope.loginUser}">

                        <a href="${pageContext.request.contextPath}/user/mypage">
                            ${sessionScope.loginUser.userId}님
                        </a>

                        <a href="${pageContext.request.contextPath}/user/logout">
                            로그아웃
                        </a>

                    </c:when>

                    <c:otherwise>

                        <a href="${pageContext.request.contextPath}/user/login">
                            로그인
                        </a>

                        <a class="join-link"
                           href="${pageContext.request.contextPath}/user/join">
                            회원가입
                        </a>

                    </c:otherwise>

                </c:choose>

            </div>

        </div>

    </div>

</header>