package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.List;
import com.example.demo.util.LongListJsonConverter;

@Entity
@Table(name = "squads")
/**
 * 小队实体
 * 用途：描述兴趣小队的基础信息、成员列表、邀请码及加入策略
 * 使用说明：memberIds 以 JSON 列保存成员ID；通过服务层维护人数与状态，避免直接修改持久化字段引发不一致
 */
public class Squad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 移除自定义UID，直接使用数据库ID作为唯一标识

    @NotBlank(message = "小队名称不能为空")
    @Size(min = 2, max = 50, message = "小队名称长度必须在2-50之间")
    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String tags;

    @Min(value = 2, message = "人数上限至少为2")
    private Integer maxMembers;

    private Integer currentMembers;

    private String status;

    private LocalDateTime createdAt;
    
    @Column(unique = true)
    private String inviteCode;
    
    private Boolean allowIdJoin;

    @ManyToOne
    @JoinColumn(name = "owner_id", nullable = false)
    @NotNull(message = "必须指定创建者")
    private User owner;
    
    @Convert(converter = LongListJsonConverter.class)
    @Column(columnDefinition = "json")
    private List<Long> memberIds;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = "RECRUITING";
        }
        if (this.currentMembers == null) {
            this.currentMembers = 1;
        }
        if (this.allowIdJoin == null) {
            this.allowIdJoin = true;
        }
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public Integer getMaxMembers() { return maxMembers; }
    public void setMaxMembers(Integer maxMembers) { this.maxMembers = maxMembers; }
    public Integer getCurrentMembers() { return currentMembers; }
    public void setCurrentMembers(Integer currentMembers) { this.currentMembers = currentMembers; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public User getOwner() { return owner; }
    public void setOwner(User owner) { this.owner = owner; }
    public List<Long> getMemberIds() { return memberIds; }
    public void setMemberIds(List<Long> memberIds) { this.memberIds = memberIds; }
    public String getInviteCode() { return inviteCode; }
    public void setInviteCode(String inviteCode) { this.inviteCode = inviteCode; }
    public Boolean getAllowIdJoin() { return allowIdJoin; }
    public void setAllowIdJoin(Boolean allowIdJoin) { this.allowIdJoin = allowIdJoin; }
}
