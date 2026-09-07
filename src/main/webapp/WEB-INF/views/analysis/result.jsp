<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
        <c:choose>
            <c:when test="${inspection.sourceType eq 'EXTERNAL_INTEGRATION'}">
                <div class="summary-card">
                    <div class="summary-label">정상 처리 장비</div>
                    <div class="summary-value normal">${inspection.successDeviceCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">정상 처리</div>
                    <div class="summary-value normal">${inspection.successCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">실패 장비</div>
                    <div class="summary-value abnormal">${inspection.failureDeviceCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">실패 처리</div>
                    <div class="summary-value abnormal">${inspection.errorCount}</div>
                </div>
            </c:when>
            <c:when test="${inspection.sourceType eq 'EXTERNAL_RETRANSMISSION'}">
                <div class="summary-card">
                    <div class="summary-label">전체 처리</div>
                    <div class="summary-value total">${inspection.successCount + inspection.errorCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">정상 처리</div>
                    <div class="summary-value normal">${inspection.successCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">실패 처리</div>
                    <div class="summary-value abnormal">${inspection.errorCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">전체 로그</div>
                    <div class="summary-value total">${inspection.totalLines}</div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="summary-card">
                    <div class="summary-label">전체 로그</div>
                    <div class="summary-value total">${inspection.totalLines}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">정상 로그</div>
                    <div class="summary-value normal">${normalCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">이상 로그</div>
                    <div class="summary-value abnormal">${inspection.abnormalLogCount}</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">오류율</div>
                    <div class="summary-value rate">
                        <fmt:formatNumber value="${errorRate}" pattern="0.00"/>%
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
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
                <td>
                    <c:choose>
                        <c:when test="${inspection.insStatus eq 'COMPLETED'}">분석 완료</c:when>
                        <c:when test="${inspection.insStatus eq 'PROCESSING'}">분석 중</c:when>
                        <c:when test="${inspection.insStatus eq 'FAILED'}">분석 실패</c:when>
                        <c:otherwise><c:out value="${inspection.insStatus}" /></c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>파일명</th>
                <td colspan="3"><c:out value="${inspection.fileName}" /></td>
            <tr>
                <th>
                    <c:choose>
                        <c:when test="${inspection.sourceType eq 'EXTERNAL_INTEGRATION' or inspection.sourceType eq 'EXTERNAL_RETRANSMISSION'}">
                            실패 결과 건
                        </c:when>
                        <c:otherwise>
                            탐지 결과 건
                        </c:otherwise>
                    </c:choose>
                </th>
                <td>${inspection.errorCount}</td>
                <th>이상 로그 건</th>
                <td>${inspection.abnormalLogCount}</td>
            </tr>
        </table>
    </section>

    <c:choose>
        <c:when test="${inspection.sourceType eq 'EXTERNAL_INTEGRATION' or inspection.sourceType eq 'EXTERNAL_RETRANSMISSION'}">
            <section class="result-box">
                <div class="box-title">
                    정상 처리 결과
                    <span class="count-badge">${inspection.successCount}건</span>
                </div>
                <c:choose>
                    <c:when test="${inspection.sourceType eq 'EXTERNAL_INTEGRATION' and not empty successDeviceSummary}">
                        <div class="success-device-list">
                            <c:forEach var="device" items="${successDeviceGroups}">
                                <details class="success-device-group">
                                    <summary>
                                        <span class="success-device-id"><c:out value="${device.key}" /></span>
                                        <span class="success-device-count">${fn:length(device.value)}건 정상</span>
                                    </summary>
                                    <div class="success-detail-table-wrap">
                                        <table class="success-detail-table">
                                            <thead>
                                                <tr>
                                                    <th>라인</th>
                                                    <th>처리 내용</th>
                                                    <th>원본 로그</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="result" items="${device.value}">
                                                    <tr>
                                                        <td>${result.lineNo}</td>
                                                        <td class="success-result-value"><c:out value="${result.detectedValue}" /></td>
                                                        <td class="log-content"><c:out value="${result.logContent}" /></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </details>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:when test="${inspection.sourceType eq 'EXTERNAL_RETRANSMISSION' and not empty successResults}">
                        <div class="success-device-list">
                            <c:forEach var="result" items="${successResults}" varStatus="status">
                                <details class="success-device-group">
                                    <summary>
                                        <span class="success-device-id">
                                            <c:choose>
                                                <c:when test="${not empty result.deviceId}">
                                                    <c:out value="${result.deviceId}" />
                                                </c:when>
                                                <c:otherwise>
                                                    정상 처리 #${status.count}
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span class="success-device-count"><c:out value="${result.detectedValue}" /></span>
                                    </summary>
                                    <div class="success-detail-table-wrap">
                                        <table class="success-detail-table">
                                            <thead>
                                                <tr>
                                                    <th>라인</th>
                                                    <th>장비</th>
                                                    <th>처리 결과</th>
                                                    <th>원본 로그</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <td>${result.lineNo}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty result.deviceId}">
                                                                <c:out value="${result.deviceId}" />
                                                            </c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="success-result-value"><c:out value="${result.detectedValue}" /></td>
                                                    <td class="log-content"><c:out value="${result.logContent}" /></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </details>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty">정상 처리 결과가 없습니다.</div>
                    </c:otherwise>
                </c:choose>
            </section>

            <section class="result-box">
                <div class="box-title">
                    실패 결과
                    <span class="count-badge error-badge">${inspection.errorCount}건</span>
                </div>
                <c:choose>
                    <c:when test="${empty failureGroups}">
                        <div class="empty">실패한 처리 결과가 없습니다.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="failure-list">
                            <c:forEach var="group" items="${failureGroups}">
                                <details class="failure-group">
                                    <summary>
                                        <span class="failure-name"><c:out value="${group.key}" /></span>
                                        <span class="failure-meta">
                                            ${fn:length(group.value)}건
                                            <c:if test="${failureDeviceCounts[group.key] > 0}">
                                                / ${failureDeviceCounts[group.key]}대
                                            </c:if>
                                        </span>
                                    </summary>
                                    <div class="failure-detail-table-wrap">
                                        <table class="failure-detail-table">
                                            <thead>
                                                <tr>
                                                    <th>라인</th>
                                                    <th>장비</th>
                                                    <th>분석 규칙</th>
                                                    <th>원본 로그</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="result" items="${group.value}">
                                                    <tr>
                                                        <td>${result.lineNo}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty result.deviceId}">
                                                                    <c:out value="${result.deviceId}" />
                                                                </c:when>
                                                                <c:otherwise>-</c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <div class="rule-name"><c:out value="${result.ruleType}" /></div>
                                                            <div class="rule-description"><c:out value="${result.ruleDescription}" /></div>
                                                        </td>
                                                        <td class="log-content">
                                                            <span class="raw-log"><c:out value="${result.logContent}" /></span>
                                                            <span class="highlight-value" hidden><c:out value="${result.detectedValue}" /></span>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </details>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </c:when>

        <c:otherwise>
            <section class="result-box">
                <div class="box-title">
                    이상 탐지 결과
                    <span class="count-badge" id="resultCount">${inspection.errorCount}건</span>
                </div>
                <c:choose>
                    <c:when test="${empty results}">
                        <div class="empty">탐지된 이상 로그가 없습니다.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="result-filter">
                            <select id="ruleFilter">
                                <option value="">전체 분석 규칙</option>
                            </select>
                            <input type="text" id="valueFilter" placeholder="탐지 값 검색">
                            <button type="button" id="filterReset">초기화</button>
                        </div>
                        <table class="result-table">
                            <thead>
                                <tr>
                                    <th class="col-line">라인</th>
                                    <th class="col-rule">탐지 규칙</th>
                                    <th class="col-value">탐지 값</th>
                                    <th>원본 로그</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="result" items="${results}">
                                    <tr class="result-row" data-rule="<c:out value="${result.ruleType}" />" data-value="<c:out value="${result.detectedValue}" />">
                                        <td>${result.lineNo}</td>
                                        <td>
                                            <div class="rule-name"><c:out value="${result.ruleType}" /></div>
                                            <div class="rule-description"><c:out value="${result.ruleDescription}" /></div>
                                        </td>
                                        <td class="detected-value"><c:out value="${result.detectedValue}" /></td>
                                        <td class="log-content">
                                            <span class="raw-log"><c:out value="${result.logContent}" /></span>
                                            <span class="highlight-value" hidden><c:out value="${result.detectedValue}" /></span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </section>
        </c:otherwise>
    </c:choose>

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

if (ruleFilter && valueFilter && filterReset) {
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
            const visible = (!selectedRule || rule === selectedRule) && (!searchValue || value.includes(searchValue));
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
}
</script>

</body>
</html>