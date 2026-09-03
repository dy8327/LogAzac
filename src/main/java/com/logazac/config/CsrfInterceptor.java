package com.logazac.config;

import java.security.SecureRandom;
import java.util.Base64;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Spring Security 없이 동작하는 최소한의 CSRF 방어 장치.
 *
 * 동작 방식 (synchronizer token 패턴):
 * 1. 세션마다 무작위 토큰을 하나 발급해 세션에 저장한다.
 * 2. POST/PUT/DELETE 요청은 요청 파라미터 "_csrf" 값이
 *    세션에 저장된 토큰과 일치해야만 통과시킨다.
 * 3. 화면(JSP)에서는 ${sessionScope.csrfToken} 으로 토큰을 읽어
 *    폼에 hidden input으로 넣어주면 된다.
 */
@Component
public class CsrfInterceptor implements HandlerInterceptor {

    public static final String SESSION_ATTR = "csrfToken";
    public static final String PARAM_NAME = "_csrf";

    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    public boolean preHandle(
        HttpServletRequest request,
        HttpServletResponse response,
        Object handler
    ) throws Exception {

        HttpSession session = request.getSession();

        String sessionToken = (String) session.getAttribute(SESSION_ATTR);

        // 세션에 토큰이 없으면 새로 발급 (최초 방문, 세션 만료 등)
        if (sessionToken == null) {
            sessionToken = generateToken();
            session.setAttribute(SESSION_ATTR, sessionToken);
        }

        String method = request.getMethod();

        boolean isStateChanging =
            "POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method);

        if (isStateChanging) {

            String requestToken = request.getParameter(PARAM_NAME);

            if (requestToken == null || !requestToken.equals(sessionToken)) {

                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().write(
                    "<h1>잘못된 요청입니다.</h1>"
                    + "<p>보안 토큰이 없거나 만료되었습니다. 이전 페이지로 돌아가 다시 시도해 주세요.</p>"
                );

                return false;
            }
        }

        return true;
    }

    private String generateToken() {

        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);

        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
