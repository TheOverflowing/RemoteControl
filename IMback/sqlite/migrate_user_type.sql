-- 为现有用户表添加user_type字段的迁移脚本
-- 如果user_type字段不存在，则添加它
ALTER TABLE user ADD COLUMN user_type TEXT DEFAULT 'normal';

-- 更新现有用户为普通用户类型
UPDATE user SET user_type = 'normal' WHERE user_type IS NULL OR user_type = ''; 