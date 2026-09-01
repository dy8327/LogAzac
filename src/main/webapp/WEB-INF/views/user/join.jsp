<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>회원가입 - LogAzac</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/user.css">
</head>

<body>

<jsp:include page="../common/header.jsp" />

<main class="user-main">

    <section class="user-box">

        <h1>회원가입</h1>

        <p class="user-description">
            LogAzac 계정을 만들어 로그 분석 기능을 이용해보세요.
        </p>

        <c:if test="${not empty errorMessage}">
            <div class="error-message">
                ${errorMessage}
            </div>
        </c:if>

        <form id="joinForm" action="${pageContext.request.contextPath}/user/join" method="post">

            <!-- 아이디 -->
            <div class="form-group">

                <label for="userId">
                    아이디
                </label>

                <div class="input-check-row">

                    <input type="text" id="userId" name="userId" value="${user.userId}" maxlength="20" required>

                    <button type="button" id="checkIdBtn" class="check-btn">
                        중복 확인
                    </button>

                </div>

                <div id="userIdMessage" class="check-message">
                </div>

            </div>

            <!-- 비밀번호 -->
            <div class="form-group">

                <label for="userPw">
                    비밀번호
                </label>

                <input type="password" id="userPw" name="userPw" minlength="4" maxlength="100" required>

            </div>

            <!-- 비밀번호 확인 -->
            <div class="form-group">

                <label for="userPwConfirm">
                    비밀번호 확인
                </label>

                <input type="password" id="userPwConfirm" name="userPwConfirm" minlength="4" maxlength="100" required>

                <div id="passwordMessage" class="check-message">
                </div>

            </div>

            <!-- 이메일 -->
            <div class="form-group">

                <label for="userEmail">
                    이메일
                </label>

                <div class="input-check-row">

                    <input type="email" id="userEmail" name="userEmail" value="${user.userEmail}" maxlength="50" required>

                    <button type="button" id="checkEmailBtn" class="check-btn">
                        중복 확인
                    </button>

                </div>

                <div id="userEmailMessage" class="check-message">
                </div>

            </div>

            <button type="submit" class="user-submit">
                가입하기
            </button>

        </form>

        <div class="user-link">
            이미 계정이 있으신가요?

            <a href="${pageContext.request.contextPath}/user/login">
                로그인
            </a>
        </div>

    </section>

</main>

<jsp:include page="../common/footer.jsp" />

<script>
const contextPath = "${pageContext.request.contextPath}";
const joinForm = document.getElementById("joinForm");
const userId = document.getElementById("userId");
const userEmail = document.getElementById("userEmail");
const userPw =  document.getElementById("userPw");
const userPwConfirm = document.getElementById("userPwConfirm");
const userIdMessage = document.getElementById("userIdMessage");
const userEmailMessage = document.getElementById("userEmailMessage");
const passwordMessage = document.getElementById("passwordMessage");

let idChecked = false;
let emailChecked = false;

/* 아이디 입력값 변경 시 중복확인 초기화 */
userId.addEventListener("input", function() {

    idChecked = false;

    userIdMessage.textContent = "";
    userIdMessage.className = "check-message";
});

/* 이메일 입력값 변경 시 중복확인 초기화 */
userEmail.addEventListener("input", function() {

    emailChecked = false;

    userEmailMessage.textContent = "";
    userEmailMessage.className = "check-message";
});

/* 아이디 중복 확인 */
document.getElementById("checkIdBtn")
    .addEventListener("click", async function() {

        const value = userId.value.trim();

        if (!value) {

            userIdMessage.textContent = "아이디를 입력해주세요.";
            userIdMessage.className = "check-message error";

            return;
        }

        try {

            const response = await fetch(
                contextPath + "/user/check-id?userId=" + encodeURIComponent(value));

            const data = await response.json();

            if (data.available) {

                idChecked = true;

                userIdMessage.textContent = "사용 가능한 아이디입니다.";
                userIdMessage.className = "check-message success";

            } else {

                idChecked = false;

                userIdMessage.textContent = "이미 사용 중인 아이디입니다.";
                userIdMessage.className = "check-message error";
            }

        } catch (error) {

            idChecked = false;

            userIdMessage.textContent = "중복 확인 중 오류가 발생했습니다.";
            userIdMessage.className = "check-message error";
        }
    });

/* 이메일 중복 확인 */
document.getElementById("checkEmailBtn")
    .addEventListener("click", async function() {

        const value = userEmail.value.trim();

        if (!value) {

            userEmailMessage.textContent = "이메일을 입력해주세요.";
            userEmailMessage.className = "check-message error";

            return;
        }

        if (!userEmail.checkValidity()) {

            userEmailMessage.textContent = "올바른 이메일 형식으로 입력해주세요.";
            userEmailMessage.className = "check-message error";

            return;
        }

        try {

            const response = await fetch(
                contextPath + "/user/check-email?userEmail=" + encodeURIComponent(value));

            const data = await response.json();

            if (data.available) {

                emailChecked = true;

                userEmailMessage.textContent = "사용 가능한 이메일입니다.";
                userEmailMessage.className = "check-message success";

            } else {

                emailChecked = false;

                userEmailMessage.textContent = "이미 사용 중인 이메일입니다.";
                userEmailMessage.className = "check-message error";
            }

        } catch (error) {

            emailChecked = false;

            userEmailMessage.textContent = "중복 확인 중 오류가 발생했습니다.";
            userEmailMessage.className = "check-message error";
        }
    });

/* 비밀번호 확인 */
function checkPassword() {

    if (!userPwConfirm.value) {

        passwordMessage.textContent = "";
        passwordMessage.className = "check-message";

        return false;
    }

    if (userPw.value === userPwConfirm.value) {

        passwordMessage.textContent = "비밀번호가 일치합니다.";
        passwordMessage.className = "check-message success";

        return true;
    }

    passwordMessage.textContent = "비밀번호가 일치하지 않습니다.";
    passwordMessage.className = "check-message error";

    return false;
}

userPw.addEventListener("input", checkPassword);
userPwConfirm.addEventListener("input", checkPassword);

/* 회원가입 제출 */
joinForm.addEventListener("submit", function(event) {

        if (!idChecked) {

            event.preventDefault();

            alert("아이디 중복 확인을 해주세요.");

            userId.focus();

            return;
        }

        if (!checkPassword()) {

            event.preventDefault();

            alert("비밀번호를 확인해주세요.");

            userPwConfirm.focus();

            return;
        }

        if (!emailChecked) {

            event.preventDefault();

            alert("이메일 중복 확인을 해주세요.");

            userEmail.focus();
        }
    }
);
</script>

</body>
</html>