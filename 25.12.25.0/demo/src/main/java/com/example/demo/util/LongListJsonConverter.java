package com.example.demo.util;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Converter
/**
 * Long 列表 JSON 转换器
 * 用途：在 JPA 持久化过程中，将 List<Long> 与 JSON 字符串互转，以便存储到 JSON 列
 * 使用说明：仅处理纯数字ID列表；复杂对象请改用更完整的序列化方案或关系表映射
 */
public class LongListJsonConverter implements AttributeConverter<List<Long>, String> {
    @Override
    public String convertToDatabaseColumn(List<Long> attribute) {
        List<Long> safe = (attribute == null) ? Collections.emptyList() : attribute;
        StringBuilder sb = new StringBuilder();
        sb.append('[');
        for (int i = 0; i < safe.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append(safe.get(i));
        }
        sb.append(']');
        return sb.toString();
    }

    @Override
    public List<Long> convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isBlank()) return Collections.emptyList();
        String s = dbData.trim();
        if (s.startsWith("[") && s.endsWith("]")) {
            s = s.substring(1, s.length() - 1);
        }
        if (s.isBlank()) return Collections.emptyList();
        String[] parts = s.split(",");
        List<Long> result = new ArrayList<>();
        for (String p : parts) {
            try {
                if (!p.isBlank()) result.add(Long.parseLong(p.trim()));
            } catch (NumberFormatException ignored) {}
        }
        return result;
    }
}
