<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>LogAzac - 로그 분석</title>
</head>

<body>

<h1>로그 이상 분석</h1>

<form action="${pageContext.request.contextPath}/analysis/upload" method="post" enctype="multipart/form-data">

    <div>
        <label for="sourceType">로그 종류</label>

        <select id="sourceType" name="sourceType" required>

            <option value="">선택</option>
            <option value="VENDING">자판기 로그</option>
            <option value="PAYMENT">결제기 로그</option>

        </select>
    </div>

    <br>

    <div>
        <label for="logFile">로그 파일</label>

        <input type="file" id="logFile" name="logFile" accept=".txt,.log" required>
    </div>

    <br>

    <button type="submit">
        로그 분석 시작
    </button>

</form>

</body>
</html>