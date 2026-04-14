package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 修改密码请求
 * 用途：承载旧密码与新密码
 * 使用说明：服务层进行复杂强度校验并执行加密更新
 */
public class ChangePasswordRequest {
    @NotBlank(message = "旧密码不能为空")
    private String oldPassword;

    @NotBlank(message = "新密码不能为空")
    private String newPassword;

    // Getters and Setters
    public String getOldPassword() { return oldPassword; }
    public void setOldPassword(String oldPassword) { this.oldPassword = oldPassword; }

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}
