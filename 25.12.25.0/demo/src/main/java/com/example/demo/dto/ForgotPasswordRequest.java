package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 忘记密码请求
 * 用途：通过用户名或邮箱发起密码重置
 * 使用说明：服务层生成短期有效令牌并返回
 */
public class ForgotPasswordRequest {
    @NotBlank(message = "邮箱或用户名不能为空")
    private String identity;

    public String getIdentity() { return identity; }
    public void setIdentity(String identity) { this.identity = identity; }
}
