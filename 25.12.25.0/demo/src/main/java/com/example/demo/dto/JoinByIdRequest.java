package com.example.demo.dto;

import jakarta.validation.constraints.NotNull;

/**
 * 按ID加入小队请求
 * 用途：提交用户ID与小队ID以加入指定小队
 * 使用说明：仅当小队允许 ID 邀请时有效
 */
public class JoinByIdRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    @NotNull(message = "小队ID不能为空")
    private Long squadId;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getSquadId() { return squadId; }
    public void setSquadId(Long squadId) { this.squadId = squadId; }
}
