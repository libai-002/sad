-- 创建新用户 funzone，密码 funzone123
CREATE USER IF NOT EXISTS 'funzone'@'%' IDENTIFIED BY 'funzone123';
-- 授予所有权限
GRANT ALL PRIVILEGES ON *.* TO 'funzone'@'%';
-- 刷新权限
FLUSH PRIVILEGES;
