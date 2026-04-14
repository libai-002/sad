package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 登录请求
 * 用途：承载登录接口所需的用户名与密码
 * 使用说明：服务层进行密码匹配校验
 */
public class LoginRequest {

    @NotBlank(message = "用户名不能为空")
    private String username;

    @NotBlank(message = "密码不能为空")
    private String password;

    // Getters and Setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
