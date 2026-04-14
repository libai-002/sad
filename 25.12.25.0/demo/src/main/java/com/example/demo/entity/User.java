package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import com.example.demo.util.LongListJsonConverter;

@Entity
@Table(name = "users")
/**
 * 用户实体
 * 用途：存储平台用户的基本资料、好友关系、加入小队记录及第三方标识
 * 使用说明：通过 JPA Repository 进行增删改查；joinedSquadIds 使用属性转换器以 JSON 列存储
 */

public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度必须在3-20之间")
    @Column(unique = true, nullable = false)
    private String username;

    @NotBlank(message = "密码不能为空")
    @Column(nullable = false)
    private String password;

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    @Column(unique = true, nullable = false)
    private String email;

    private String role;

    private String nickname;

    @Column(columnDefinition = "TEXT")
    private String bio;

    private String tags; // Comma separated tags

    private String contactInfo;

    private String avatarUrl;

    private LocalDateTime createdAt;
    
    private String resetToken;
    
    private LocalDateTime resetTokenExpiresAt;
    
    @Convert(converter = LongListJsonConverter.class)
    @Column(columnDefinition = "json")
    private List<Long> joinedSquadIds;
    
    @ManyToMany
    @JoinTable(
        name = "user_friends",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "friend_id")
    )
    private Set<User> friends = new HashSet<>();
    
    @Column(unique = true)
    private String wechatOpenId;
    
    @Column(unique = true)
    private String wechatUnionId;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.role == null) {
            this.role = "USER";
        }
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

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
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }
    
    public LocalDateTime getResetTokenExpiresAt() { return resetTokenExpiresAt; }
    public void setResetTokenExpiresAt(LocalDateTime resetTokenExpiresAt) { this.resetTokenExpiresAt = resetTokenExpiresAt; }
    
    public Set<User> getFriends() { return friends; }
    public void setFriends(Set<User> friends) { this.friends = friends; }
    
    public List<Long> getJoinedSquadIds() { return joinedSquadIds; }
    public void setJoinedSquadIds(List<Long> joinedSquadIds) { this.joinedSquadIds = joinedSquadIds; }
    
    public String getWechatOpenId() { return wechatOpenId; }
    public void setWechatOpenId(String wechatOpenId) { this.wechatOpenId = wechatOpenId; }
    
    public String getWechatUnionId() { return wechatUnionId; }
    public void setWechatUnionId(String wechatUnionId) { this.wechatUnionId = wechatUnionId; }
}
