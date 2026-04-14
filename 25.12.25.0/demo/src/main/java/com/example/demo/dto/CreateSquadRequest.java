package com.example.demo.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 创建小队请求
 * 用途：承载创建小队所需的名称、标签、人数上限与创建者ID
 * 使用说明：服务层根据 ownerId 初始化成员列表与默认状态
 */
public class CreateSquadRequest {
    @NotBlank(message = "名称不能为空")
    @Size(min = 2, max = 50, message = "名称长度需在2-50之间")
    private String name;
    private String description;
    private String tags;
    @NotNull(message = "人数上限不能为空")
    @Min(value = 2, message = "人数上限至少为2")
    private Integer maxMembers;
    @NotNull(message = "创建者ID不能为空")
    private Long ownerId;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public Integer getMaxMembers() { return maxMembers; }
    public void setMaxMembers(Integer maxMembers) { this.maxMembers = maxMembers; }
    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }
}
