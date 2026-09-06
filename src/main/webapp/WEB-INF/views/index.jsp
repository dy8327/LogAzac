<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LogAzac - 운영 로그 분석 시스템</title>
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
                OPERATION LOG ANALYSIS
            </div>

            <h1>
                운영로그를 분석해<br>
                <span>상태와 결과를 한눈에</span>
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
                    다양한 운영 로그 파일을
                    간단하게 업로드할 수 있습니다.
                </p>
            </article>

            <article class="feature-card">
                <div class="feature-number">02</div>
                <h3>상태·결과 판정</h3>
                <p>
                    등록된 분석 규칙과 로그 흐름을 기준으로
                    상태 변화와 처리 결과를 자동으로 판정합니다.
                </p>
            </article>

            <article class="feature-card">
                <div class="feature-number">03</div>
                <h3>분석 결과 확인</h3>
                <p>
                    판정 결과와 이상 값, 원본 로그를
                    한 화면에서 확인할 수 있습니다.
                </p>
            </article>

        </div>

    </section>

</main>

<jsp:include page="common/footer.jsp" />

</body>
</html>