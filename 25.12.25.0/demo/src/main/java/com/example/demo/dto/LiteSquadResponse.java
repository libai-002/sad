package com.example.demo.dto;

/**
 * 简化版小队响应
 * 用途：返回小队的基础信息，不包含邀请码
 * 使用说明：由服务层装配，用于前端列表展示等不需要邀请码的场景
 */
import java.util.List;

public class LiteSquadResponse {
    private Long id;
    private String name;
    private String description;
    private String tags;
    private Integer maxMembers;
    private Integer currentMembers;
    private String status;
    private Long ownerId;
    private String ownerName;
    private Boolean allowIdJoin;
    private List<Long> memberIds;

    public LiteSquadResponse() {}

    public LiteSquadResponse(Long id, String name, String description, String tags,
                             Integer maxMembers, Integer currentMembers, String status,
                             Long ownerId, String ownerName, Boolean allowIdJoin,
                             List<Long> memberIds) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.tags = tags;
        this.maxMembers = maxMembers;
        this.currentMembers = currentMembers;
        this.status = status;
        this.ownerId = ownerId;
        this.ownerName = ownerName;
        this.allowIdJoin = allowIdJoin;
        this.memberIds = memberIds;
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
    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }
    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }
    public Boolean getAllowIdJoin() { return allowIdJoin; }
    public void setAllowIdJoin(Boolean allowIdJoin) { this.allowIdJoin = allowIdJoin; }
    public List<Long> getMemberIds() { return memberIds; }
    public void setMemberIds(List<Long> memberIds) { this.memberIds = memberIds; }
}
