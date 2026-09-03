<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - LogAzac</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/mypage.css">
</head>

<body>

<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="mypage" />
</jsp:include>

<main class="mypage-main">

    <section class="mypage-header">
        <div class="mypage-title-wrap">
            <img src="${pageContext.request.contextPath}/resources/images/member.png" alt="마이페이지 카피바라" class="mypage-character">
            <div>
                <h1>마이페이지</h1>
                <p>회원 정보와 업로드한 로그 파일을 관리할 수 있습니다.</p>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/analysis/history" class="history-btn">검사 이력</a>
    </section>

    <c:if test="${not empty successMessage}">
        <div class="success-message">
            ${successMessage}
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="error-message">
            ${errorMessage}
        </div>
    </c:if>

    <section class="mypage-box">

        <div class="section-title">
            <h2>내 정보</h2>
        </div>

        <div class="user-info">

            <div class="info-item">
                <span class="info-label">아이디</span>
                <span class="info-value">${user.userId}</span>
            </div>

            <div class="info-item">
                <span class="info-label">이메일</span>
                <span class="info-value">${user.userEmail}</span>
            </div>

        </div>

    </section>

    <section class="mypage-box">

        <div class="section-title">
            <h2>업로드 파일</h2>
            <span class="count">${logFiles.size()}건</span>
        </div>

        <div class="table-wrap">

            <table>

                <thead>
                <tr>
                    <th>파일번호</th>
                    <th>파일명</th>
                    <th>로그 종류</th>
                    <th>파일 크기</th>
                    <th>관리</th>
                </tr>
                </thead>

                <tbody>

                <c:choose>

                    <c:when test="${empty logFiles}">
                        <tr>
                            <td colspan="5" class="empty-message">
                                업로드한 파일이 없습니다.
                            </td>
                        </tr>
                    </c:when>

                    <c:otherwise>

                        <c:forEach var="file" items="${logFiles}">

                            <tr>

                                <td>
                                    ${file.fileNo}
                                </td>

                                <td class="file-name">
                                    ${file.fileName}
                                </td>

                                <td>
                                    <span class="source-type">
                                        ${file.sourceType}
                                    </span>
                                </td>

                                <td>
                                    ${file.fileSize} byte
                                </td>

                                <td>
                                    <form action="${pageContext.request.contextPath}/user/mypage/delete-file" method="post" class="delete-form">

                                        <input type="hidden" name="fileNo" value="${file.fileNo}">

                                        <button type="button" class="delete-btn" onclick="openDeleteModal(this)">
                                            삭제
                                        </button>

                                    </form>
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

<div id="deleteModal" class="modal-overlay">

    <div class="delete-modal">

        <h3>파일 삭제</h3>

        <p>
            업로드한 원본 파일을 삭제하시겠습니까?
        </p>

        <p class="modal-guide">
            검사 이력과 분석 결과는 그대로 유지됩니다.
        </p>

        <div class="modal-buttons">

            <button type="button" class="modal-cancel" onclick="closeDeleteModal()">
                취소
            </button>

            <button type="button" class="modal-delete" onclick="confirmDelete()">
                삭제
            </button>

        </div>

    </div>

</div>

<script>
let deleteForm = null;

function openDeleteModal(button) {
    deleteForm = button.closest(".delete-form");
    document.getElementById("deleteModal").classList.add("show");
}

function closeDeleteModal() {
    document.getElementById("deleteModal").classList.remove("show");
    deleteForm = null;
}

function confirmDelete() {
    if (deleteForm) {
        deleteForm.submit();
    }
}
</script>

<jsp:include page="../common/footer.jsp" />

</body>
</html>