package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 按邀请码加入小队请求
 * 用途：提交用户ID与邀请码以加入对应小队
 * 使用说明：服务层校验邀请码有效性与容量边界
 */
public class JoinByCodeRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    @NotBlank(message = "邀请码不能为空")
    private String inviteCode;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getInviteCode() { return inviteCode; }
    public void setInviteCode(String inviteCode) { this.inviteCode = inviteCode; }
}
