package com.example.demo.dto;

/**
 * 好友响应
 * 用途：向前端返回好友的基本展示信息
 * 使用说明：用于个人资料页的好友列表
 */
public class FriendResponse {
    private Long id;
    private String username;
    private String nickname;
    private String avatarUrl;

    public FriendResponse() {}

    public FriendResponse(Long id, String username, String nickname, String avatarUrl) {
        this.id = id;
        this.username = username;
        this.nickname = nickname;
        this.avatarUrl = avatarUrl;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
}
