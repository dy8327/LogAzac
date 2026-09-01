package com.logazac.controller;

import java.util.Map;
import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.logazac.dto.UserDTO;
import com.logazac.service.UserService;

@Controller
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/user/join")
    public String joinForm() {
        return "user/join";
    }

    // 아이디 중복 확인
    @GetMapping("/user/check-id")
    @ResponseBody
    public Map<String, Boolean> checkUserId(
        @RequestParam("userId") String userId
    ) {

        boolean duplicate =
            userService.isUserIdDuplicate(userId);

        return Map.of("available", !duplicate);
    }

    // 이메일 중복 확인
    @GetMapping("/user/check-email")
    @ResponseBody
    public Map<String, Boolean> checkUserEmail(
        @RequestParam("userEmail") String userEmail
    ) {

        boolean duplicate = userService.isUserEmailDuplicate(userEmail);

        return Map.of("available", !duplicate);
    }

    @PostMapping("/user/join")
    public String join(
        UserDTO user,
        @RequestParam("userPwConfirm") String userPwConfirm,
        Model model
    ) {

        try {

            // 비밀번호 확인
            if (!user.getUserPw().equals(userPwConfirm)) {
                throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
            }

            userService.join(user);

            return "redirect:/user/login";

        } catch (IllegalArgumentException e) {

            model.addAttribute("errorMessage", e.getMessage());
            model.addAttribute("user", user);

            return "user/join";
        }
    }

    @GetMapping("/user/login")
    public String loginForm() {
        return "user/login";
    }

    @PostMapping("/user/login")
    public String login(
        @RequestParam("userId") String userId,
        @RequestParam("userPw") String userPw,
        HttpSession session,
        Model model
    ) {

        try {

            UserDTO loginUser = userService.login(userId, userPw);

            // 세션에는 비밀번호를 보관하지 않음
            loginUser.setUserPw(null);
            session.setAttribute("loginUser", loginUser);

            return "redirect:/";

        } catch (IllegalArgumentException e) {

            model.addAttribute("errorMessage", e.getMessage());
            model.addAttribute("userId", userId);

            return "user/login";
        }
    }

    @GetMapping("/user/logout")
    public String logout(HttpSession session) {

        session.invalidate();

        return "redirect:/";
    }

    @GetMapping("/user/mypage")
    public String mypage(HttpSession session, Model model) {

        UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            return "redirect:/user/login";
        }

        model.addAttribute("user", loginUser);

        return "user/mypage";
    }
}