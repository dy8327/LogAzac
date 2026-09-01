<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<header class="site-header">
    <div class="site-header-inner">

        <a class="site-logo"
           href="${pageContext.request.contextPath}/analysis">
            Log<span>Azac</span>
        </a>

        <nav class="site-nav">
            <a class="${param.activeMenu eq 'analysis' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/analysis">
                로그 분석
            </a>

            <a class="${param.activeMenu eq 'history' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/analysis/history">
                검사 이력
            </a>
        </nav>

    </div>
</header>