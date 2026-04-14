package com.example.demo.dto;

import jakarta.validation.constraints.NotNull;

/**
 * 按ID退出小队请求
 * 用途：提交用户ID与小队ID以退出指定小队
 * 使用说明：服务层维护人数与成员列表的同步更新
 */
public class LeaveByIdRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    @NotNull(message = "小队ID不能为空")
    private Long squadId;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getSquadId() { return squadId; }
    public void setSquadId(Long squadId) { this.squadId = squadId; }
}
