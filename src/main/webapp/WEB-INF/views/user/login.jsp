<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>로그인 - LogAzac</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/user.css">
</head>

<body>

<jsp:include page="../common/header.jsp" />

<main class="user-main">

    <section class="user-box">

        <h1>로그인</h1>

        <p class="user-description">
            LogAzac에 로그인하여 검사 이력을 관리하세요.
        </p>

        <c:if test="${not empty errorMessage}">
            <div class="error-message">
                ${errorMessage}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/user/login"
              method="post">

            <div class="form-group">

                <label for="userId">
                    아이디
                </label>

                <input type="text" id="userId" name="userId" value="${userId}" maxlength="20" required>

            </div>

            <div class="form-group">

                <label for="userPw">
                    비밀번호
                </label>

                <input type="password" id="userPw" name="userPw" required>

            </div>

            <button type="submit" class="user-submit">
                로그인
            </button>

        </form>

        <div class="user-link">

            아직 계정이 없으신가요?

            <a href="${pageContext.request.contextPath}/user/join">
                회원가입
            </a>

        </div>

    </section>

</main>

<jsp:include page="../common/footer.jsp" />

</body>
</html>