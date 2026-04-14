package com.example.demo.config;

import org.springframework.stereotype.Component;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@Component
/**
 * 数据库维护组件
 * 用途：应用启动后检查并清理数据库遗留结构（示例：删除 squads 表的 uid 列）
 * 使用说明：在 @PostConstruct 阶段执行；异常被吞并以避免影响启动流程
 */
public class DatabaseMaintenance {
    private final DataSource dataSource;
    public DatabaseMaintenance(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @jakarta.annotation.PostConstruct
    public void init() {
        try (Connection conn = dataSource.getConnection();
             Statement st = conn.createStatement()) {
            boolean hasUid = false;
            try (ResultSet rs = st.executeQuery(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'squads' AND COLUMN_NAME = 'uid'")) {
                if (rs.next()) {
                    hasUid = rs.getInt(1) > 0;
                }
            }
            if (hasUid) {
                st.executeUpdate("ALTER TABLE squads DROP COLUMN uid");
            }
        } catch (Exception ignored) {}
    }
}
