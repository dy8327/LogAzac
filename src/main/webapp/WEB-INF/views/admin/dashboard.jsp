<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 대시보드 - LogAzac</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin-dashboard.css">
</head>
<body>
<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="admin" />
</jsp:include>

<main class="dashboard-main">
    <section class="dashboard-header">
        <div class="dashboard-title-wrap">
            <img src="${pageContext.request.contextPath}/resources/images/admin.png" alt="관리자 카피바라" class="admin-character">
            <div>
                <span class="dashboard-label">ADMIN DASHBOARD</span>
                <h1>통계 대시보드</h1>
                <p>LogAzac의 전체 로그 분석 현황입니다.</p>
            </div>
        </div>
        <a class="analysis-link" href="${pageContext.request.contextPath}/admin/inspections">전체 검사 이력</a>
    </section>

    <section class="summary-grid">
        <article class="summary-card">
            <span class="card-label">전체 회원</span>
            <strong><fmt:formatNumber value="${summary.userCount}" />명</strong>
            <p>가입된 전체 회원</p>
        </article>

        <article class="summary-card">
            <span class="card-label">누적 업로드</span>
            <strong><fmt:formatNumber value="${summary.fileCount}" />건</strong>
            <p>삭제된 파일을 포함한 누적 수</p>
        </article>

        <article class="summary-card">
            <span class="card-label">완료된 검사</span>
            <strong><fmt:formatNumber value="${summary.inspectionCount}" />건</strong>
            <p>정상 완료된 분석</p>
        </article>

        <article class="summary-card cyan">
            <span class="card-label">전체 로그</span>
            <strong><fmt:formatNumber value="${summary.totalLineCount}" />줄</strong>
            <p>완료된 검사 기준</p>
        </article>

        <article class="summary-card red">
            <span class="card-label">이상 로그</span>
            <strong><fmt:formatNumber value="${summary.abnormalLogCount}" />줄</strong>
            <p>이상이 탐지된 로그 라인</p>
        </article>

        <article class="summary-card orange">
            <span class="card-label">탐지 결과</span>
            <strong><fmt:formatNumber value="${summary.detectionCount}" />건</strong>
            <p>한 로그의 중복 탐지 포함</p>
        </article>
    </section>

    <section class="chart-grid">
        <article class="dashboard-panel">
            <div class="panel-header">
                <div>
                    <h2>기간별 검사 현황</h2>
                    <p>최근 7일 동안의 검사 및 이상 로그</p>
                </div>
            </div>
            <div class="chart-container">
                <canvas id="dailyChart"></canvas>
            </div>
        </article>

        <article class="dashboard-panel">
            <div class="panel-header">
                <div>
                    <h2>이상 유형별 현황</h2>
                    <p>탐지 규칙별 발생 건수</p>
                </div>
            </div>
            <div class="chart-container">
                <canvas id="ruleChart"></canvas>
            </div>
        </article>
    </section>
    <section class="admin-menu">
        <a class="admin-menu-card" href="${pageContext.request.contextPath}/admin/users">
            <strong>회원관리</strong>
            <span>회원 계정 및 차단 상태 관리</span>
        </a>
        <a class="admin-menu-card" href="${pageContext.request.contextPath}/admin/files">
            <strong>로그파일 관리</strong>
            <span>전체 업로드 파일 현황 확인</span>
        </a>
        <a class="admin-menu-card" href="${pageContext.request.contextPath}/admin/rules">
            <strong>이상 판단 규칙 관리</strong>
            <span>탐지 규칙 조회 및 설정</span>
        </a>
    </section>

</main>

<jsp:include page="../common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script>
    const dailyLabels = [
        <c:forEach var="daily" items="${dailyStatistics}" varStatus="status">
            "${daily.statDate}"<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const inspectionData = [
        <c:forEach var="daily" items="${dailyStatistics}" varStatus="status">
            ${daily.inspectionCount}<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const abnormalData = [
        <c:forEach var="daily" items="${dailyStatistics}" varStatus="status">
            ${daily.abnormalLogCount}<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const ruleLabels = [
        <c:forEach var="rule" items="${ruleStatistics}" varStatus="status">
            "${rule.ruleType}"<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const ruleData = [
        <c:forEach var="rule" items="${ruleStatistics}" varStatus="status">
            ${rule.count}<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    new Chart(document.getElementById("dailyChart"), {
        data: {
            labels: dailyLabels,
            datasets: [
                {
                    type: "bar",
                    label: "검사 건수",
                    data: inspectionData,
                    backgroundColor: "rgba(255, 193, 7, 0.45)",
                    borderColor: "#e0a800",
                    borderWidth: 1,
                    borderRadius: 5,
                    yAxisID: "inspectionAxis"
                },
                {
                    type: "line",
                    label: "이상 로그",
                    data: abnormalData,
                    borderColor: "#ff7777",
                    backgroundColor: "rgba(255, 119, 119, 0.15)",
                    borderWidth: 2,
                    pointBackgroundColor: "#ff7777",
                    pointRadius: 4,
                    tension: 0.3,
                    fill: true,
                    yAxisID: "abnormalAxis"
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: "index",
                intersect: false
            },
            plugins: {
                legend: {
                    labels: {
                        color: "#b8c1c9",
                        boxWidth: 14
                    }
                }
            },
            scales: {
                x: {
                    ticks: {
                        color: "#617a70"
                    },
                    grid: {
                        color: "rgba(15, 81, 50, 0.14)"
                    }
                },
                inspectionAxis: {
                    position: "left",
                    beginAtZero: true,
                    ticks: {
                        color: "#ffd43b",
                        precision: 0
                    },
                    grid: {
                        color: "rgba(90, 104, 117, 0.15)"
                    }
                },
                abnormalAxis: {
                    position: "right",
                    beginAtZero: true,
                    ticks: {
                        color: "#ff7777",
                        precision: 0
                    },
                    grid: {
                        drawOnChartArea: false
                    }
                }
            }
        }
    });
    new Chart(document.getElementById("ruleChart"), {
        type: "doughnut",
        data: {
            labels: ruleLabels,
            datasets: [{
                data: ruleData,
                backgroundColor: [
                    "#ffd43b",
                    "#ff7777",
                    "#66c7d4",
                    "#ffad66",
                    "#a78bfa",
                    "#7ee787",
                    "#f472b6",
                    "#60a5fa"
                ],
                borderColor: "#151e28",
                borderWidth: 3,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: "62%",
            plugins: {
                legend: {
                    position: "bottom",
                    labels: {
                        color: "#49685c",
                        padding: 16,
                        boxWidth: 12,
                        boxHeight: 12
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return context.label + ": " + context.raw + "건";
                        }
                    }
                }
            }
        }
    });
</script>
</body>
</html>