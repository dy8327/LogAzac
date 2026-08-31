<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib prefix="c"
           uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>LogAzac - 분석 결과</title>

    <style>
        table {
            border-collapse: collapse;
            width: 100%;
        }

        th,
        td {
            border: 1px solid #ccc;
            padding: 8px;
            text-align: left;
        }

        .log-content {
            max-width: 700px;
            word-break: break-all;
            font-size: 13px;
        }
    </style>
</head>

<body>

<h1>로그 분석 결과</h1>


<h2>검사 정보</h2>

<table>

    <tr>
        <th>검사 번호</th>
        <td>${inspection.insNo}</td>

        <th>분석 상태</th>
        <td>${inspection.insStatus}</td>
    </tr>

    <tr>
        <th>파일명</th>
        <td>${inspection.fileName}</td>

        <th>로그 종류</th>
        <td>${inspection.sourceType}</td>
    </tr>

    <tr>
        <th>총 로그 건</th>
        <td>${inspection.totalLines}</td>

        <th>이상 탐지 건</th>
        <td>${inspection.errorCount}</td>
    </tr>

</table>


<h2>이상 탐지 결과</h2>


<c:choose>

    <c:when test="${empty results}">

        <p>
            탐지된 이상 로그가 없습니다.
        </p>

    </c:when>


    <c:otherwise>

        <table>

            <thead>

            <tr>
                <th>라인</th>
                <th>탐지 규칙</th>
                <th>탐지 값</th>
                <th>원본 로그</th>
            </tr>

            </thead>


            <tbody>

            <c:forEach var="result"
                       items="${results}">

                <tr>

                    <td>
                        ${result.lineNo}
                    </td>

                    <td>
                        ${result.ruleType}
                        <br>
                        <small>
                            ${result.ruleDescription}
                        </small>
                    </td>

                    <td>
                        ${result.detectedValue}
                    </td>

                    <td class="log-content">
                        ${result.logContent}
                    </td>

                </tr>

            </c:forEach>

            </tbody>

        </table>

    </c:otherwise>

</c:choose>


<br>

<a href="${pageContext.request.contextPath}/analysis">
    다른 로그 분석하기
</a>

</body>

</html>