package com.example.demo.service;

import com.example.demo.dto.CreateSquadRequest;
import com.example.demo.dto.SquadResponse;
import com.example.demo.dto.LiteSquadResponse;
import com.example.demo.entity.Squad;
import com.example.demo.entity.User;
import com.example.demo.repository.SquadRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.UserHistoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
/**
 * 小队业务服务
 * 用途：管理小队的创建、加入/退出、成员与人数维护、搜索与推荐、邀请码生成与策略设置
 * 使用说明：严格校验容量与重复加入；写操作统一使用事务，确保用户与小队状态一致
 */
public class SquadService {

    private final SquadRepository squadRepository;
    private final UserRepository userRepository;
    private final UserHistoryService userHistoryService;

    public SquadService(SquadRepository squadRepository, UserRepository userRepository, UserHistoryService userHistoryService) {
        this.squadRepository = squadRepository;
        this.userRepository = userRepository;
        this.userHistoryService = userHistoryService;
    }

    @Transactional
    public SquadResponse createSquad(CreateSquadRequest request) {
        User owner = userRepository.findById(request.getOwnerId())
                .orElseThrow(() -> new RuntimeException("创建者不存在"));

        Squad squad = new Squad();
        squad.setName(request.getName());
        squad.setDescription(request.getDescription());
        squad.setTags(request.getTags());
        squad.setMaxMembers(request.getMaxMembers());
        squad.setOwner(owner);
        java.util.List<Long> mids = new java.util.ArrayList<>();
        mids.add(owner.getId());
        squad.setMemberIds(mids);

        Squad saved = squadRepository.save(squad);
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<SquadResponse> listByOwner(Long ownerId) {
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return squadRepository.findByOwner(owner).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public SquadResponse getById(Long id) {
        Squad s = squadRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("小队不存在"));
        return toResponse(s);
    }

    @Transactional
    public SquadResponse joinById(Long userId, Long squadId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        Squad squad = squadRepository.findById(squadId)
                .orElseThrow(() -> new RuntimeException("小队不存在"));
        if (Boolean.FALSE.equals(squad.getAllowIdJoin())) {
            throw new RuntimeException("该小队已关闭ID邀请");
        }
        java.util.List<Long> ids = user.getJoinedSquadIds();
        if (ids == null) {
            ids = new java.util.ArrayList<>();
        } else {
            ids = new java.util.ArrayList<>(ids);
        }
        if (ids.contains(squadId)) {
            return toResponse(squad);
        }
        if (ids.size() >= 5) {
            throw new RuntimeException("已加入数量达上限");
        }
        if (squad.getCurrentMembers() != null && squad.getMaxMembers() != null &&
                squad.getCurrentMembers() >= squad.getMaxMembers()) {
            throw new RuntimeException("小队已满员");
        }
        ids.add(squadId);
        user.setJoinedSquadIds(ids);
        java.util.List<Long> mids = squad.getMemberIds();
        if (mids == null) {
            mids = new java.util.ArrayList<>();
        } else {
            mids = new java.util.ArrayList<>(mids);
        }
        if (!mids.contains(userId)) {
            mids.add(userId);
        }
        squad.setMemberIds(mids);
        squad.setCurrentMembers((squad.getCurrentMembers() == null ? 0 : squad.getCurrentMembers()) + 1);
        userRepository.save(user);
        Squad saved = squadRepository.save(squad);
        return toResponse(saved);
    }

    private SquadResponse toResponse(Squad s) {
        return new SquadResponse(
                s.getId(),
                s.getName(),
                s.getDescription(),
                s.getTags(),
                s.getMaxMembers(),
                s.getCurrentMembers(),
                s.getStatus(),
                s.getOwner().getId(),
                s.getOwner().getUsername(),
                s.getInviteCode(),
                s.getAllowIdJoin(),
                s.getMemberIds()
        );
    }
    
    private LiteSquadResponse toLiteResponse(Squad s) {
        return new LiteSquadResponse(
                s.getId(),
                s.getName(),
                s.getDescription(),
                s.getTags(),
                s.getMaxMembers(),
                s.getCurrentMembers(),
                s.getStatus(),
                s.getOwner().getId(),
                s.getOwner().getUsername(),
                s.getAllowIdJoin(),
                s.getMemberIds()
        );
    }

    @Transactional
    public void leaveById(Long userId, Long squadId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        Squad squad = squadRepository.findById(squadId)
                .orElseThrow(() -> new RuntimeException("小队不存在"));
        java.util.List<Long> ids = user.getJoinedSquadIds();
        if (ids == null || !ids.contains(squadId)) {
            throw new RuntimeException("未加入该小队");
        }
        Integer cm = squad.getCurrentMembers() == null ? 0 : squad.getCurrentMembers();
        if (cm > 0) {
            squad.setCurrentMembers(cm - 1);
        }
        ids.removeIf(x -> x.equals(squadId));
        user.setJoinedSquadIds(ids);
        java.util.List<Long> mids = squad.getMemberIds();
        if (mids != null) {
            mids.removeIf(x -> x.equals(userId));
            squad.setMemberIds(mids);
        }
        userRepository.save(user);
        squadRepository.save(squad);
    }
    
    @Transactional(readOnly = true)
    public List<SquadResponse> listJoined(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        java.util.List<Long> ids = user.getJoinedSquadIds();
        if (ids == null || ids.isEmpty()) return java.util.List.of();
        return squadRepository.findAllById(ids).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<SquadResponse> searchByTagEquals(String tag) {
        if (tag == null || tag.trim().isEmpty()) {
            return java.util.List.of();
        }
        String kw = tag.trim();
        return squadRepository.findAll().stream()
                .filter(s -> {
                    String t = s.getTags();
                    if (t == null || t.isEmpty()) return false;
                    String[] parts = t.split("[,，\\s]+");
                    for (String p : parts) {
                        if (kw.equals(p.trim())) return true;
                    }
                    return false;
                })
                .map(this::toResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<SquadResponse> listRecommended(int limit) {
        int capped = (limit <= 0 || limit > 8) ? 8 : limit;
        return squadRepository.findRandomRecommended(capped).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public SquadResponse generateInviteCode(Long squadId) {
        Squad squad = squadRepository.findById(squadId)
                .orElseThrow(() -> new RuntimeException("小队不存在"));
        String chars = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
        String code = null;
        int attempts = 0;
        while (attempts < 10) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 8; i++) {
                int idx = (int) Math.floor(Math.random() * chars.length());
                sb.append(chars.charAt(idx));
            }
            String candidate = sb.toString();
            if (squadRepository.findByInviteCode(candidate).isEmpty()) {
                code = candidate;
                break;
            }
            attempts++;
        }
        if (code == null) {
            throw new RuntimeException("邀请码生成失败，请重试");
        }
        squad.setInviteCode(code);
        try {
            Squad saved = squadRepository.save(squad);
            return toResponse(saved);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            throw new RuntimeException("邀请码生成失败，请重试");
        }
    }
    
    @Transactional
    public SquadResponse setAllowIdJoin(Long squadId, boolean allow) {
        Squad squad = squadRepository.findById(squadId)
                .orElseThrow(() -> new RuntimeException("小队不存在"));
        squad.setAllowIdJoin(allow);
        Squad saved = squadRepository.save(squad);
        return toResponse(saved);
    }
    
    @Transactional
    public SquadResponse joinByInviteCode(Long userId, String inviteCode) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        Squad squad = squadRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new RuntimeException("邀请码无效"));
        java.util.List<Long> ids = user.getJoinedSquadIds();
        if (ids == null) {
            ids = new java.util.ArrayList<>();
        } else {
            ids = new java.util.ArrayList<>(ids);
        }
        if (ids.contains(squad.getId())) {
            return toResponse(squad);
        }
        if (ids.size() >= 5) {
            throw new RuntimeException("已加入数量达上限");
        }
        if (squad.getCurrentMembers() != null && squad.getMaxMembers() != null &&
                squad.getCurrentMembers() >= squad.getMaxMembers()) {
            throw new RuntimeException("小队已满员");
        }
        ids.add(squad.getId());
        user.setJoinedSquadIds(ids);
        java.util.List<Long> mids = squad.getMemberIds();
        if (mids == null) {
            mids = new java.util.ArrayList<>();
        } else {
            mids = new java.util.ArrayList<>(mids);
        }
        if (!mids.contains(userId)) {
            mids.add(userId);
        }
        squad.setMemberIds(mids);
        squad.setCurrentMembers((squad.getCurrentMembers() == null ? 0 : squad.getCurrentMembers()) + 1);
        userRepository.save(user);
        Squad saved = squadRepository.save(squad);
        return toResponse(saved);
    }
    
    @Transactional
    public SquadResponse join(Long userId, String identifier) {
        if (identifier == null || identifier.trim().isEmpty()) {
            throw new RuntimeException("加入标识符不能为空");
        }
        
        // 判断是数字ID还是邀请码
        if (identifier.matches("\\d+")) {
            // 是数字ID
            try {
                Long squadId = Long.parseLong(identifier);
                return joinById(userId, squadId);
            } catch (NumberFormatException e) {
                throw new RuntimeException("无效的小队ID");
            }
        } else {
            // 是邀请码
            return joinByInviteCode(userId, identifier);
        }
    }
    
    @Transactional(readOnly = true)
    public List<SquadResponse> getRandomUniqueSquads(Long userId, int limit) {
        // 获取用户已查看的小队ID集合
        java.util.Set<Long> viewedSquadIds = userHistoryService.getViewedSquads(userId);
        
        // 获取所有小队
        List<Squad> allSquads = squadRepository.findAll();
        
        // 过滤掉已查看的小队
        List<Squad> availableSquads = allSquads.stream()
                .filter(squad -> !viewedSquadIds.contains(squad.getId()))
                .collect(java.util.stream.Collectors.toList());
        
        // 如果没有可用小队，返回空列表
        if (availableSquads.isEmpty()) {
            return java.util.List.of();
        }
        
        // 随机打乱可用小队
        java.util.Collections.shuffle(availableSquads);
        
        // 选择指定数量的小队，最多4个
        int actualLimit = Math.min(limit, 4);
        List<Squad> selectedSquads = availableSquads.stream()
                .limit(actualLimit)
                .collect(java.util.stream.Collectors.toList());
        
        // 提取选中小队的ID
        List<Long> selectedSquadIds = selectedSquads.stream()
                .map(Squad::getId)
                .collect(java.util.stream.Collectors.toList());
        
        // 将选中的小队添加到用户的已查看列表
        userHistoryService.addViewedSquads(userId, selectedSquadIds);
        
        // 转换为响应对象并返回
        return selectedSquads.stream()
                .map(this::toResponse)
                .collect(java.util.stream.Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<LiteSquadResponse> getRandomUniqueSquadsLite(Long userId, int limit) {
        // 获取用户已查看的小队ID集合
        java.util.Set<Long> viewedSquadIds = userHistoryService.getViewedSquads(userId);
        
        // 获取所有小队
        List<Squad> allSquads = squadRepository.findAll();
        
        // 过滤掉已查看的小队
        List<Squad> availableSquads = allSquads.stream()
                .filter(squad -> !viewedSquadIds.contains(squad.getId()))
                .collect(java.util.stream.Collectors.toList());
        
        // 如果没有可用小队，返回空列表
        if (availableSquads.isEmpty()) {
            return java.util.List.of();
        }
        
        // 随机打乱可用小队
        java.util.Collections.shuffle(availableSquads);
        
        // 选择指定数量的小队，最多4个
        int actualLimit = Math.min(limit, 4);
        List<Squad> selectedSquads = availableSquads.stream()
                .limit(actualLimit)
                .collect(java.util.stream.Collectors.toList());
        
        // 提取选中小队的ID
        List<Long> selectedSquadIds = selectedSquads.stream()
                .map(Squad::getId)
                .collect(java.util.stream.Collectors.toList());
        
        // 将选中的小队添加到用户的已查看列表
        userHistoryService.addViewedSquads(userId, selectedSquadIds);
        
        // 转换为简化响应对象并返回
        return selectedSquads.stream()
                .map(this::toLiteResponse)
                .collect(java.util.stream.Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<LiteSquadResponse> listRecommendedLite(int limit) {
        int capped = (limit <= 0 || limit > 8) ? 8 : limit;
        return squadRepository.findRandomRecommended(capped).stream()
                .map(this::toLiteResponse)
                .collect(java.util.stream.Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<LiteSquadResponse> searchByTagEqualsLite(String tag) {
        if (tag == null || tag.trim().isEmpty()) {
            return java.util.List.of();
        }
        String kw = tag.trim();
        return squadRepository.findAll().stream()
                .filter(s -> {
                    String t = s.getTags();
                    if (t == null || t.isEmpty()) return false;
                    String[] parts = t.split("[,，\\s]+");
                    for (String p : parts) {
                        if (kw.equals(p.trim())) return true;
                    }
                    return false;
                })
                .map(this::toLiteResponse)
                .collect(java.util.stream.Collectors.toList());
    }
}
