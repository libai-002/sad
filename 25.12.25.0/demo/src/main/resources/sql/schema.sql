-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS funzone;

-- 使用数据库
USE funzone;

-- 创建用户表（如果不存在）
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(20) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '加密后的密码',
    email VARCHAR(255) NOT NULL UNIQUE COMMENT '邮箱地址',
    role VARCHAR(50) DEFAULT 'USER' COMMENT '用户角色',
    created_at DATETIME(6) COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
