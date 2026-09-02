<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>이상 판단 규칙 등록 - LogAzac</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-history.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin-rule.css">
</head>
<body>
<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="admin" />
</jsp:include>

<main class="page-wrap">
    <section class="page-header">
            <div>
                <h1>이상 판단 규칙 등록</h1>
                <p>로그 분석에 사용할 새 규칙을 등록합니다.</p>
            </div>
            <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/rules">목록</a>
        </section>

        <section class="history-box rule-form">
        <form action="${pageContext.request.contextPath}/admin/rules" method="post">
            <div class="form-group">
                <label for="detRuleType">규칙 유형</label>
                <input type="text" id="detRuleType" name="detRuleType" required>
            </div>
            <div class="form-group">
                <label for="detPattern">패턴</label>
                <input type="text" id="detPattern" name="detPattern" required>
            </div>
            <div class="form-group">
                <label for="detDescription">설명</label>
                <textarea id="detDescription" name="detDescription" required></textarea>
            </div>
            <div class="form-group">
                <label for="useYn">사용 여부</label>
                <select id="useYn" name="useYn">
                    <option value="Y">사용</option>
                    <option value="N">미사용</option>
                </select>
            </div>
            <div class="form-actions">
                <a class="analysis-btn" href="${pageContext.request.contextPath}/admin/rules">취소</a>
                <button class="action-btn" type="submit">등록</button>
            </div>
        </form>
    </section>
</main>

<jsp:include page="../common/footer.jsp" />
</body>
</html>