<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>LogAzac - 분석 결과</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-result.css">
</head>

<body>

<c:set var="normalCount" value="${inspection.totalLines - inspection.abnormalLogCount}" />
<c:set var="errorRate"
       value="${inspection.totalLines > 0
           ? inspection.abnormalLogCount * 100.0 / inspection.totalLines
           : 0}" />
<jsp:include page="../common/header.jsp">
        <jsp:param name="activeMenu" value="analysis" />
    </jsp:include>

<main class="page-wrap">
    <div class="result-title-wrap">
        <img src="${pageContext.request.contextPath}/resources/images/result.png" alt="분석결과 카피바라" class="result-character">
        <h1 class="title">검사 <span>완료!</span></h1>
    </div>

    <section class="summary-grid">
        <div class="summary-card">
            <div class="summary-label">
                전체 로그
            </div>
            <div class="summary-value total">
                ${inspection.totalLines}
            </div>
        </div>
        <div class="summary-card">
            <div class="summary-label">
                정상 로그
            </div>
            <div class="summary-value normal">
                ${normalCount}
            </div>
        </div>
        <div class="summary-card">
            <div class="summary-label">
                이상 로그
            </div>
            <div class="summary-value abnormal">
                ${inspection.abnormalLogCount}
            </div>
        </div>
        <div class="summary-card">
            <div class="summary-label">
                오류율
            </div>
            <div class="summary-value rate">
                <fmt:formatNumber
                    value="${errorRate}"
                    pattern="0.00" />%
            </div>
        </div>
    </section>

    <section class="info-box">
        <div class="box-title">
            검사 정보
        </div>

        <table class="info-table">
            <tr>
                <th>검사 번호</th>
                <td>${inspection.insNo}</td>
                <th>분석 상태</th>
                <td>${inspection.insStatus}</td>
            </tr>
            <tr>
                <th>파일명</th>
                <td colspan="3">${inspection.fileName}</td>
            <tr>
                <th>탐지 결과 건</th>
                <td>${inspection.errorCount}</td>
                <th>이상 로그 건</th>
                <td>${inspection.abnormalLogCount}</td>
            </tr>
        </table>
    </section>

    <section class="result-box">
        <div class="box-title">
            이상 탐지 결과
            <span class="count-badge" id="resultCount">
                ${inspection.errorCount}건
            </span>
        </div>

        <c:choose>
            <c:when test="${empty results}">
                <div class="empty">
                    탐지된 이상 로그가 없습니다.
                </div>

            </c:when>
            <c:otherwise>
                <div class="result-filter">
                    <select id="ruleFilter">
                        <option value="">전체 탐지 규칙</option>
                    </select>
                    <input type="text" id="valueFilter" placeholder="탐지 값 검색">
                    <button type="button" id="filterReset">초기화</button>
                </div>
                <table class="result-table">
                    <thead>
                    <tr>
                        <th class="col-line">
                            라인
                        </th>
                        <th class="col-rule">
                            탐지 규칙
                        </th>
                        <th class="col-value">
                            탐지 값
                        </th>
                        <th>
                            원본 로그
                        </th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach var="result" items="${results}">
                        <tr class="result-row" data-rule="${result.ruleType}" data-value="${result.detectedValue}">
                            <td>
                                ${result.lineNo}
                            </td>
                            <td>
                                <div class="rule-name">
                                    ${result.ruleType}
                                </div>
                                <div class="rule-description">
                                    ${result.ruleDescription}
                                </div>
                            </td>
                            <td class="detected-value">
                                ${result.detectedValue}
                            </td>
                            <td class="log-content">
                                <span class="raw-log">${result.logContent}</span>
                                <span class="highlight-value" hidden>${result.detectedValue}</span>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </section>

    <div class="actions">
        <a class="btn secondary" href="${pageContext.request.contextPath}/analysis/history">검사 이력</a>
        <a class="btn" href="${pageContext.request.contextPath}/analysis">다른 로그 분석하기</a>
    </div>
   
</main>
 <jsp:include page="../common/footer.jsp" />


<script>
document.querySelectorAll(".log-content").forEach(function(container) {
    const logElement = container.querySelector(".raw-log");
    const valueElement = container.querySelector(".highlight-value");

    const logContent = logElement.textContent;
    const detectedValue = valueElement.textContent.trim();

    if (!detectedValue) {
        return;
    }

    let highlightValues = [];

    // PRICE_CHANGED / PRODUCT_NAME_CHANGED
    // 예: 2500 -> 3000
    // 예: 포켓몬볼 -> 피카츄
    if (detectedValue.includes("->")) {
        const values = detectedValue.split("->");

        const errorValue = values[0].trim();

        if (errorValue) {
            highlightValues.push(errorValue);
        }
} else {
        // 일반 탐지 값
        highlightValues.push(detectedValue);
    }

    highlightValues = highlightValues.filter(function(value) {
        return value && logContent.includes(value);
    });

    if (highlightValues.length === 0) {
        return;
    }

    highlightValues.sort(function(a, b) {
        return b.length - a.length;
    });

    const matches = [];

    highlightValues.forEach(function(value) {
        let index = logContent.indexOf(value);

        while (index !== -1) {
            matches.push({
                start: index,
                end: index + value.length,
                value: value
            });

            index = logContent.indexOf(value, index + value.length);
        }
    });

    matches.sort(function(a, b) {
        return a.start - b.start;
    });

    const filteredMatches = [];

    matches.forEach(function(match) {
        const last = filteredMatches[filteredMatches.length - 1];

        if (!last || match.start >= last.end) {
            filteredMatches.push(match);
        }
    });

    const fragment = document.createDocumentFragment();

    let currentIndex = 0;

    filteredMatches.forEach(function(match) {
        if (match.start > currentIndex) {
            fragment.appendChild(
                document.createTextNode(
                    logContent.substring(
                        currentIndex,
                        match.start
                    )
                )
            );
        }

        const highlight = document.createElement("span");

        highlight.className = "log-highlight";
        highlight.textContent = match.value;

        fragment.appendChild(highlight);

        currentIndex = match.end;
    });

    if (currentIndex < logContent.length) {
        fragment.appendChild(
            document.createTextNode(
                logContent.substring(currentIndex)
            )
        );
    }

    logElement.textContent = "";
    logElement.appendChild(fragment);
});
//결과 필터
const ruleFilter = document.getElementById("ruleFilter");
const valueFilter = document.getElementById("valueFilter");
const filterReset = document.getElementById("filterReset");
const resultRows = document.querySelectorAll(".result-row");

const ruleSet = new Set();

resultRows.forEach(function(row) {
    const rule = row.dataset.rule.trim();
    if (rule) ruleSet.add(rule);
});

ruleSet.forEach(function(rule) {
    const option = document.createElement("option");
    option.value = rule;
    option.textContent = rule;
    ruleFilter.appendChild(option);
});

function applyResultFilter() {
    const selectedRule = ruleFilter.value;
    const searchValue = valueFilter.value.trim().toLowerCase();
    let visibleCount = 0;

    resultRows.forEach(function(row) {
        const rule = row.dataset.rule;
        const value = row.dataset.value.toLowerCase();
        const ruleMatch = !selectedRule || rule === selectedRule;
        const valueMatch = !searchValue || value.includes(searchValue);
        const visible = ruleMatch && valueMatch;

        row.style.display = visible ? "" : "none";
        if (visible) visibleCount++;
    });

    document.getElementById("resultCount").textContent = visibleCount + "건";
}

ruleFilter.addEventListener("change", applyResultFilter);
valueFilter.addEventListener("input", applyResultFilter);

filterReset.addEventListener("click", function() {
    ruleFilter.value = "";
    valueFilter.value = "";
    applyResultFilter();
});
</script>

</body>
</html>