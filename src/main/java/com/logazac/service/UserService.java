package com.logazac.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.logazac.dto.UserDTO;
import com.logazac.mapper.UserMapper;

@Service
public class UserService {

    private final UserMapper userMapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public boolean isUserIdDuplicate(String userId) {
        return userMapper.countByUserId(userId) > 0;
    }

    public boolean isUserEmailDuplicate(String userEmail) {
        return userMapper.countByUserEmail(userEmail) > 0;
    }

    @Transactional
    public int join(UserDTO user) {

        if (isUserIdDuplicate(user.getUserId())) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }

        if (isUserEmailDuplicate(user.getUserEmail())) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }

        String encodedPassword = passwordEncoder.encode(user.getUserPw());

        user.setUserPw(encodedPassword);

        return userMapper.insertUser(user);
    }

    public UserDTO login(String userId, String userPw) {

        UserDTO user = userMapper.findByUserId(userId);

        if (user == null) {
            throw new IllegalArgumentException("아이디 또는 비밀번호가 일치하지 않습니다.");
        }

        if ("Y".equals(user.getBlockYn())) {
            throw new IllegalArgumentException("사용이 제한된 계정입니다.");
        }

        if (!passwordEncoder.matches(userPw, user.getUserPw())) {
            throw new IllegalArgumentException("아이디 또는 비밀번호가 일치하지 않습니다.");
        }

        return user;
    }
}