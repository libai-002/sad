package com.example.demo.dto;

/**
 * 更新资料请求
 * 用途：承载用户资料的可修改字段
 * 使用说明：允许部分字段为空表示不修改；服务层进行非空判断与持久化
 */
public class UpdateProfileRequest {
    private String nickname;
    private String bio;
    private String tags;
    private String contactInfo;
    private String avatarUrl;

    // Getters and Setters
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }

    public String getContactInfo() { return contactInfo; }
    public void setContactInfo(String contactInfo) { this.contactInfo = contactInfo; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
}
