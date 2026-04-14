package com.example.demo.repository;

import com.example.demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

/**
 * 用户仓库
 * 用途：提供用户实体的持久化访问方法与常见查询
 * 使用说明：通过方法命名派生查询（findByUsername/Email），也支持微信标识查询
 */
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    Optional<User> findByWechatOpenId(String wechatOpenId);
    Optional<User> findByWechatUnionId(String wechatUnionId);
}
