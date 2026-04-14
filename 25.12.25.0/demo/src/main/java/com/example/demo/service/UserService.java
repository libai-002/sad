package com.example.demo.service;

import com.example.demo.dto.RegisterRequest;
import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.UserProfileResponse;
import com.example.demo.dto.UpdateProfileRequest;
import com.example.demo.dto.ChangePasswordRequest;
import com.example.demo.dto.FriendResponse;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
/**
 * 用户业务服务
 * 用途：处理注册/登录、资料维护、密码变更与重置、好友关系管理
 * 使用说明：所有写操作使用事务；密码采用 BCrypt 加密；对边界条件进行严格校验
 */
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    @Transactional
    public User registerUser(RegisterRequest request) {
        // 1. 检查唯一性 (不合理违规：允许重复注册)
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("邮箱已存在");
        }

        // 2. 创建用户对象
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        
        // 3. 密码加密 (不合理违规：明文存储密码)
        // 合理设计：使用BCrypt进行强哈希加密
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        // 4. 保存到数据库
        return userRepository.save(user);
    }

    public User loginUser(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("密码错误");
        }
        return user;
    }

    public UserProfileResponse getUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        UserProfileResponse resp = new UserProfileResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getNickname(),
            user.getBio(),
            user.getTags(),
            user.getContactInfo(),
            user.getAvatarUrl(),
            user.getRole()
        );
        resp.setJoinedSquadIds(user.getJoinedSquadIds());
        return resp;
    }

    @Transactional
    public UserProfileResponse updateUserProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (request.getNickname() != null) user.setNickname(request.getNickname());
        if (request.getBio() != null) user.setBio(request.getBio());
        if (request.getTags() != null) user.setTags(request.getTags());
        if (request.getContactInfo() != null) user.setContactInfo(request.getContactInfo());
        if (request.getAvatarUrl() != null) user.setAvatarUrl(request.getAvatarUrl());

        User updatedUser = userRepository.save(user);
        
        UserProfileResponse resp = new UserProfileResponse(
            updatedUser.getId(),
            updatedUser.getUsername(),
            updatedUser.getEmail(),
            updatedUser.getNickname(),
            updatedUser.getBio(),
            updatedUser.getTags(),
            updatedUser.getContactInfo(),
            updatedUser.getAvatarUrl(),
            updatedUser.getRole()
        );
        resp.setJoinedSquadIds(updatedUser.getJoinedSquadIds());
        return resp;
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("旧密码错误");
        }

        String newPassword = request.getNewPassword();
        if (newPassword == null || newPassword.length() < 8) {
            throw new RuntimeException("新密码长度至少为8位");
        }
        if (newPassword.equals(request.getOldPassword())) {
            throw new RuntimeException("新密码不能与旧密码相同");
        }
        if (newPassword.equalsIgnoreCase(user.getUsername())) {
            throw new RuntimeException("新密码不能与用户名相同");
        }
        if (!newPassword.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            throw new RuntimeException("新密码需包含大小写字母和数字");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
    
    @Transactional(readOnly = true)
    public List<FriendResponse> listFriends(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return user.getFriends().stream()
                .map(f -> new FriendResponse(f.getId(), f.getUsername(), f.getNickname(), f.getAvatarUrl()))
                .collect(Collectors.toList());
    }
    
    @Transactional
    public void addFriendByUsername(Long userId, String friendUsername) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        User friend = userRepository.findByUsername(friendUsername)
                .orElseThrow(() -> new RuntimeException("好友不存在"));
        if (user.getId().equals(friend.getId())) {
            throw new RuntimeException("不能添加自己为好友");
        }
        if (user.getFriends().size() >= 100) {
            throw new RuntimeException("好友数量已达上限");
        }
        boolean already = user.getFriends().stream().anyMatch(f -> f.getId().equals(friend.getId()));
        if (already) {
            throw new RuntimeException("已是好友");
        }
        user.getFriends().add(friend);
        friend.getFriends().add(user);
        userRepository.save(user);
        userRepository.save(friend);
    }
    
    @Transactional
    public void removeFriend(Long userId, Long friendId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        User friend = userRepository.findById(friendId)
                .orElseThrow(() -> new RuntimeException("好友不存在"));
        user.getFriends().removeIf(f -> f.getId().equals(friendId));
        friend.getFriends().removeIf(f -> f.getId().equals(userId));
        userRepository.save(user);
        userRepository.save(friend);
    }
    
    @Transactional
    public String initiatePasswordReset(String identity) {
        User user = userRepository.findByUsername(identity)
                .orElseGet(() -> userRepository.findByEmail(identity)
                        .orElseThrow(() -> new RuntimeException("用户不存在")));
        String token = java.util.UUID.randomUUID().toString().replace("-", "");
        user.setResetToken(token);
        user.setResetTokenExpiresAt(java.time.LocalDateTime.now().plusMinutes(15));
        userRepository.save(user);
        return token;
    }
    
    @Transactional
    public void resetPassword(String identity, String token, String newPassword) {
        User user = userRepository.findByUsername(identity)
                .orElseGet(() -> userRepository.findByEmail(identity)
                        .orElseThrow(() -> new RuntimeException("用户不存在")));
        if (user.getResetToken() == null || user.getResetTokenExpiresAt() == null) {
            throw new RuntimeException("未发起重置请求");
        }
        if (java.time.LocalDateTime.now().isAfter(user.getResetTokenExpiresAt())) {
            throw new RuntimeException("重置令牌已过期");
        }
        if (!user.getResetToken().equals(token)) {
            throw new RuntimeException("重置令牌无效");
        }
        if (newPassword == null || newPassword.length() < 8) {
            throw new RuntimeException("新密码长度至少为8位");
        }
        if (newPassword.equalsIgnoreCase(user.getUsername())) {
            throw new RuntimeException("新密码不能与用户名相同");
        }
        if (!newPassword.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            throw new RuntimeException("新密码需包含大小写字母和数字");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setResetToken(null);
        user.setResetTokenExpiresAt(null);
        userRepository.save(user);
    }
}
