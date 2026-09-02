<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>LogAzac - 로그 이상 분석 시스템</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/home.css">
</head>

<body>

<jsp:include page="common/header.jsp">
    <jsp:param name="activeMenu" value="home" />
</jsp:include>

<main class="home-main">

    <section class="hero">

        <div class="hero-content">

            <div class="hero-label">
                LOG ANOMALY ANALYSIS
            </div>

            <h1>
                복잡한 로그에서<br>
                <span>이상 징후를 빠르게.</span>
            </h1>

            <img src="${pageContext.request.contextPath}/resources/images/logo.png"
                alt="LogAzac"
                class="hero-logo">

            <div class="hero-actions">

                <a href="${pageContext.request.contextPath}/analysis"
                class="primary-btn">
                    로그 분석 시작
                </a>

                <a href="${pageContext.request.contextPath}/analysis/history"
                class="secondary-btn">
                    검사 이력 보기
                </a>

            </div>

        </div>

    </section>

    <section class="feature-section">

        <div class="section-title">
            <span>FEATURES</span>
            <h2>로그 분석을 더 간단하게</h2>
        </div>

        <div class="feature-grid">

            <article class="feature-card">
                <div class="feature-number">01</div>
                <h3>로그 업로드</h3>
                <p>
                    자판기 및 결제기 로그 파일을
                    간단하게 업로드할 수 있습니다.
                </p>
            </article>

            <article class="feature-card">
                <div class="feature-number">02</div>
                <h3>이상 로그 탐지</h3>
                <p>
                    등록된 탐지 규칙을 기준으로
                    이상 패턴을 자동으로 찾아냅니다.
                </p>
            </article>

            <article class="feature-card">
                <div class="feature-number">03</div>
                <h3>분석 결과 확인</h3>
                <p>
                    탐지 규칙, 이상 값, 원본 로그를
                    한 화면에서 확인할 수 있습니다.
                </p>
            </article>

        </div>

    </section>

</main>

<jsp:include page="common/footer.jsp" />

</body>
</html>