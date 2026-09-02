<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>LogAzac - 로그 분석</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-history.css">
</head>
<body>

<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="analysis" />
</jsp:include>

<main class="page-wrap">
    <section class="analysis-upload-box">
        <div class="upload-panel">
            <h2>지금 바로 로그를 분석해보세요! &gt;</h2>

            <label class="upload-drop" for="logFile">
                <div class="upload-icon">☁</div>
                <p>로그 파일을 드래그하거나<br>클릭하여 업로드하세요.</p>
                <span>(TXT, LOG)</span>
                <strong>파일 선택</strong>
                <p id="selectedFileName" class="selected-file-name">선택된 파일이 없습니다.</p>
            </label>

            <form action="${pageContext.request.contextPath}/analysis/upload" method="post" enctype="multipart/form-data">
                <input type="hidden" name="sourceType" value="VENDING">
                <input type="file" id="logFile" name="logFile" accept=".txt,.log" required>
                <button type="submit" class="analysis-start-btn">로그 분석 시작</button>
            </form>
        </div>

        <div class="analysis-character">
            <img src="${pageContext.request.contextPath}/resources/images/work.png" alt="로그 분석 캐릭터">
        </div>
    </section>
</main>

<jsp:include page="../common/footer.jsp" />
<script>
document.getElementById("logFile").addEventListener("change", function() {
    const fileName = this.files.length > 0 ? this.files[0].name : "선택된 파일이 없습니다.";
    document.getElementById("selectedFileName").textContent = fileName;
});
</script>
</body>
</html>