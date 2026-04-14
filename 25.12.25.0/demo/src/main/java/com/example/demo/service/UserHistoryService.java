package com.example.demo.service;

import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 用户历史记录服务
 * 用途：跟踪用户已经看过的小队，确保每次返回的小队不重复
 * 使用说明：使用内存存储，在应用重启后会重置，但对于当前需求已足够
 */
@Service
public class UserHistoryService {

    // 存储用户ID到已查看小队ID列表的映射
    private final Map<Long, Set<Long>> userViewedSquads = new ConcurrentHashMap<>();

    /**
     * 获取用户已查看的小队ID集合
     * @param userId 用户ID
     * @return 已查看的小队ID集合
     */
    public Set<Long> getViewedSquads(Long userId) {
        return userViewedSquads.computeIfAbsent(userId, k -> new HashSet<>());
    }

    /**
     * 添加小队到用户的已查看列表
     * @param userId 用户ID
     * @param squadIds 小队ID列表
     */
    public void addViewedSquads(Long userId, List<Long> squadIds) {
        Set<Long> viewed = userViewedSquads.computeIfAbsent(userId, k -> new HashSet<>());
        viewed.addAll(squadIds);
    }

    /**
     * 检查用户是否已经查看过指定小队
     * @param userId 用户ID
     * @param squadId 小队ID
     * @return 是否已查看
     */
    public boolean hasViewed(Long userId, Long squadId) {
        Set<Long> viewed = userViewedSquads.get(userId);
        return viewed != null && viewed.contains(squadId);
    }

    /**
     * 清空用户的历史记录
     * @param userId 用户ID
     */
    public void clearHistory(Long userId) {
        userViewedSquads.remove(userId);
    }
}