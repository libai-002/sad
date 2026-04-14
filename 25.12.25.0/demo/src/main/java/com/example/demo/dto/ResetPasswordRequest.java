package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 重置密码请求
 * 用途：提交身份、重置令牌与新密码以完成重置
 * 使用说明：服务层校验令牌有效性与新密码复杂度
 */
public class ResetPasswordRequest {
    @NotBlank(message = "邮箱或用户名不能为空")
    private String identity;
    @NotBlank(message = "重置令牌不能为空")
    private String token;
    @NotBlank(message = "新密码不能为空")
    private String newPassword;

    public String getIdentity() { return identity; }
    public void setIdentity(String identity) { this.identity = identity; }
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}
