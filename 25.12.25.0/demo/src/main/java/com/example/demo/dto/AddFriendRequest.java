package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 添加好友请求
 * 用途：按好友用户名发起添加好友操作
 * 使用说明：服务层防止自添加与重复添加，并维护双向关系
 */
public class AddFriendRequest {
    @NotBlank(message = "好友用户名不能为空")
    private String username;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}
