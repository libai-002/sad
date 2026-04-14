package com.example.demo.dto;

/**
 * 用户资料响应
 * 用途：向前端返回用户的基础资料与加入小队列表
 * 使用说明：用于个人中心与仪表盘展示
 */
public class UserProfileResponse {
    private Long id;
    private String username;
    private String email;
    private String nickname;
    private String bio;
    private String tags;
    private String contactInfo;
    private String avatarUrl;
    private String role;
    private java.util.List<Long> joinedSquadIds;

    public UserProfileResponse() {}

    public UserProfileResponse(Long id, String username, String email, String nickname, String bio, String tags, String contactInfo, String avatarUrl, String role) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.nickname = nickname;
        this.bio = bio;
        this.tags = tags;
        this.contactInfo = contactInfo;
        this.avatarUrl = avatarUrl;
        this.role = role;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

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

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public java.util.List<Long> getJoinedSquadIds() { return joinedSquadIds; }
    public void setJoinedSquadIds(java.util.List<Long> joinedSquadIds) { this.joinedSquadIds = joinedSquadIds; }
}
