package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 按UID退出小队请求
 * 用途：提交用户ID与小队UID以退出（旧版本兼容）
 * 使用说明：现版本以 ID 为主，UID 字段用于兼容处理
 */
public class LeaveSquadRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    @NotBlank(message = "小队UID不能为空")
    private String uid;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getUid() { return uid; }
    public void setUid(String uid) { this.uid = uid; }
}
