package com.example.demo;

import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.UserService;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class DemoApplicationTests {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    void testRegisterAndLogin() {
        // 1. 注册测试
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setUsername("testuser");
        registerRequest.setPassword("password123");
        registerRequest.setEmail("test@example.com");

        User registeredUser = userService.registerUser(registerRequest);
        Assertions.assertNotNull(registeredUser.getId(), "用户ID不应为空");
        Assertions.assertEquals("testuser", registeredUser.getUsername(), "用户名应匹配");

        // 2. 登录测试
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsername("testuser");
        loginRequest.setPassword("password123");

        User loggedInUser = userService.loginUser(loginRequest);
        Assertions.assertEquals(registeredUser.getId(), loggedInUser.getId(), "登录用户ID应匹配注册用户ID");
        
        // 3. 错误密码登录测试
        LoginRequest wrongLogin = new LoginRequest();
        wrongLogin.setUsername("testuser");
        wrongLogin.setPassword("wrongpassword");
        
        Assertions.assertThrows(RuntimeException.class, () -> {
            userService.loginUser(wrongLogin);
        }, "错误密码应抛出异常");
    }
}
