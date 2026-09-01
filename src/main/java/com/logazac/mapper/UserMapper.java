package com.logazac.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.logazac.dto.UserDTO;

@Mapper
public interface UserMapper {

    // 회원가입
    int insertUser(UserDTO user);

    // 아이디 중복 확인
    int countByUserId(@Param("userId") String userId);

    // 이메일 중복 확인
    int countByUserEmail(@Param("userEmail") String userEmail);

    // 로그인용 회원 조회
    UserDTO findByUserId(@Param("userId") String userId);

    // 회원번호 조회
    UserDTO findByUserNo(@Param("userNo") int userNo);
}