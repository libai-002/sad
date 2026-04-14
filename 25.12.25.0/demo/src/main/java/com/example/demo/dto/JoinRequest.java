package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 统一加入小队请求
 * 用途：提交用户ID与加入标识符（小队ID或邀请码）以加入对应小队
 * 使用说明：后端会自动判断是ID还是邀请码并调用相应的加入逻辑
 */
public class JoinRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    
    @NotBlank(message = "加入标识符不能为空")
    private String identifier;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getIdentifier() { return identifier; }
    public void setIdentifier(String identifier) { this.identifier = identifier; }
}