package com.example.demo.repository;

import com.example.demo.entity.Squad;
import com.example.demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

/**
 * 小队仓库
 * 用途：访问小队实体并提供推荐/查询等数据操作
 * 使用说明：findRandomRecommended 使用原生 SQL 随机筛选未设置邀请码的小队
 */
public interface SquadRepository extends JpaRepository<Squad, Long> {
    List<Squad> findByOwner(User owner);
    Optional<Squad> findByInviteCode(String inviteCode);
    
    @Query(value = "SELECT * FROM squads WHERE invite_code IS NULL ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Squad> findRandomRecommended(@Param("limit") int limit);
}
