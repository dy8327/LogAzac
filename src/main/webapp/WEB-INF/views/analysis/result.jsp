<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LogAzac - 분석 결과</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/analysis-result.css">
    <style>.evidence { white-space: pre-wrap; overflow-wrap: anywhere; max-height: 24rem; overflow: auto; } .result-table { table-layout: auto; } .result-table td { vertical-align: top; } .status-SUCCESS { color: #187343; } .status-ERROR { color: #b42318; } .status-UNKNOWN { color: #8a5700; } .status-CHANGE { color: #2456a6; } .coverage-note { line-height: 1.7; } .table-scroll { overflow-x: auto; }</style>
</head>
<body>
<jsp:include page="../common/header.jsp"><jsp:param name="activeMenu" value="analysis" /></jsp:include>
<main class="page-wrap">
    <div class="result-title-wrap"><h1 class="title">운영 로그 분석 결과</h1></div>
    <section class="info-box">
        <p>파일: <c:out value="${inspection.displayFileName}" /> · 검사 ${inspection.insNo}</p>
        <c:choose>
            <c:when test="${inspection.schemaVersion lt 2}"><p class="coverage-note">이전 분석기로 생성된 이력입니다. 분석 범위·변경·미확인 작업 집계는 제공되지 않습니다. 최신 판정이 필요하면 파일을 다시 분석해 주세요.</p></c:when>
            <c:otherwise>
                <p class="coverage-note">전체 ${inspection.totalLines}줄에서 업무 레코드 ${inspection.parsedRecordCount}건을 읽었습니다. 미분석 ${inspection.unparsedLineCount}줄에는 메모·연결 메시지·미지원 구간이 포함됩니다. 불완전 상태 레코드 ${inspection.parseFailureCount}건은 상태 비교에서 제외했습니다. 분석되지 않은 구간은 정상으로 판정하지 않습니다.</p>
                <p>변화는 파일 내 같은 장비의 관측값 비교입니다. 값의 변화만으로 판매·보충·고장을 확정하지 않습니다.</p>
            </c:otherwise>
        </c:choose>
    </section>
    <section class="summary-grid">
        <div class="summary-card"><div class="summary-label">선택 규칙의 이상 결과</div><div class="summary-value abnormal">${inspection.errorCount}</div></div>
        <div class="summary-card"><div class="summary-label">선택 규칙의 상태 변화</div><div class="summary-value">${inspection.schemaVersion ge 2 ? inspection.changeCount : '-'}</div></div>
        <div class="summary-card"><div class="summary-label">성공 작업</div><div class="summary-value normal">${inspection.schemaVersion ge 2 ? inspection.successCount : '-'}</div></div>
        <div class="summary-card"><div class="summary-label">실패 작업</div><div class="summary-value abnormal">${inspection.schemaVersion ge 2 ? inspection.failedOperationCount : '-'}</div></div>
        <div class="summary-card"><div class="summary-label">결과 미확인 작업</div><div class="summary-value">${inspection.schemaVersion ge 2 ? inspection.unknownCount : '-'}</div></div>
    </section>
    <section class="result-box">
        <div class="box-title">업무 처리 결과</div>
        <p>작업별 관측 결과이며 장비 전체의 최종 성공을 뜻하지 않습니다. SQL 성공은 해당 SQL 실행 근거입니다. 규칙 활성 여부와 관계없이 관측된 작업을 표시합니다.</p>
        <c:if test="${empty operations}"><div class="empty">관측된 처리 작업이 없습니다.</div></c:if>
        <c:if test="${not empty operations}">
            <div class="table-scroll"><table class="result-table"><thead><tr><th>장비 / 업무일</th><th>업무 유형 / 단계</th><th>결과</th><th>근거</th></tr></thead><tbody>
            <c:forEach var="operation" items="${operations}">
                <tr>
                    <td><c:out value="${empty operation.deviceId ? '장비 미확인' : operation.deviceId}" /><br><c:out value="${operation.businessDate}" /></td>
                    <td><c:choose><c:when test="${operation.category eq 'EXTERNAL_RESEND'}">외부 시스템 재전송 로그</c:when><c:otherwise>외부 연동 데이터 로그</c:otherwise></c:choose><br><c:out value="${operation.operationLabel}" /></td>
                    <td class="status-${operation.resultStatus}"><c:choose><c:when test="${operation.resultStatus eq 'SUCCESS'}">성공</c:when><c:when test="${operation.resultStatus eq 'ERROR'}">실패</c:when><c:otherwise>결과 미확인</c:otherwise></c:choose><br><c:out value="${operation.reasonCode}" /></td>
                    <td><details><summary>${operation.lineNo}–${operation.lineEnd}줄 · 익명화된 근거</summary><pre class="evidence"><c:out value="${operation.rawLog}" /></pre></details></td>
                </tr>
            </c:forEach>
            </tbody></table></div>
        </c:if>
    </section>
    <section class="result-box">
        <div class="box-title">분석 규칙 결과 <span id="resultCount" class="count-badge"></span></div>
        <div class="result-filter">
            <select id="statusFilter" aria-label="결과 종류"><option value="">전체 결과</option><option value="ERROR">이상·실패</option><option value="CHANGE">상태 변화</option><option value="SUCCESS">성공</option><option value="UNKNOWN">미확인</option></select>
            <input id="valueFilter" type="search" placeholder="장비·규칙·내용 검색" aria-label="결과 검색">
        </div>
        <c:if test="${empty results}"><div class="empty">활성화된 규칙에서 생성된 결과가 없습니다. 이 사실만으로 전체 로그가 정상임을 의미하지 않습니다.</div></c:if>
        <div class="table-scroll"><table class="result-table"><thead><tr><th>장비 / 슬롯</th><th>규칙 / 종류</th><th>분석 내용</th><th>현재·이전 근거</th></tr></thead><tbody>
        <c:forEach var="result" items="${results}">
            <tr class="result-row" data-status="<c:out value='${result.resultStatus}' />">
                <td><c:out value="${result.deviceId}" /><br><c:out value="${result.slotCode}" /></td>
                <td><c:out value="${result.ruleDescription}" /><br><small><c:out value="${result.ruleType}" /></small><br><span class="status-${result.resultStatus}"><c:choose><c:when test="${result.resultStatus eq 'CHANGE'}">상태 변화</c:when><c:when test="${result.resultStatus eq 'SUCCESS'}">성공</c:when><c:when test="${result.resultStatus eq 'UNKNOWN'}">미확인</c:when><c:otherwise>이상·실패</c:otherwise></c:choose></span></td>
                <td><c:out value="${result.detectedValue}" /><c:if test="${not empty result.previousValue}"><br>이전: <c:out value="${result.previousValue}" /><br>현재: <c:out value="${result.currentValue}" /></c:if></td>
                <td><details><summary>현재 ${result.lineNo}줄 · 익명화된 근거</summary><pre class="evidence"><c:out value="${result.logContent}" /></pre></details><c:if test="${not empty result.previousLineNo}"><details><summary>이전 ${result.previousLineNo}줄</summary><pre class="evidence"><c:out value="${result.previousRawLog}" /></pre></details></c:if></td>
            </tr>
        </c:forEach>
        </tbody></table></div>
    </section>
    <div class="actions"><a class="btn secondary" href="${pageContext.request.contextPath}/analysis/history">검사 이력</a><a class="btn" href="${pageContext.request.contextPath}/analysis">다른 로그 분석</a></div>
</main>
<jsp:include page="../common/footer.jsp" />
<script>
const statusFilter = document.getElementById('statusFilter');
const valueFilter = document.getElementById('valueFilter');
const rows = [...document.querySelectorAll('.result-row')];
function filterResults() {
    let count = 0;
    rows.forEach(row => {
        const visible = (!statusFilter.value || row.dataset.status === statusFilter.value) && row.textContent.toLowerCase().includes(valueFilter.value.toLowerCase());
        row.hidden = !visible;
        if (visible) count++;
    });
    document.getElementById('resultCount').textContent = count + '건';
}
statusFilter.addEventListener('change', filterResults);
valueFilter.addEventListener('input', filterResults);
filterResults();
</script>
</body>
</html>
