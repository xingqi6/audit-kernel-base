# ==========================================
# 阶段 1：猎人模式 (提取核心)
# ==========================================
FROM surveyking/surveyking:latest AS source
USER root
# 提取核心 Jar 包
RUN find / -type f -name "*.jar" -size +30M -exec cp {} /core.jar \; || true

# ==========================================
# 阶段 2：稳定模式 (升级到 Ubuntu + Java 17)
# ==========================================
# ⚠️ 关键修改：使用 Java 17 (eclipse-temurin:17-jre)
# 解决了新版 SurveyKing 在 Java 8 下可能出现的静默崩溃问题
FROM eclipse-temurin:17-jre

ENV APP_NAME=audit_core_module
WORKDIR /opt

# 从第一阶段复制文件
COPY --from=source /core.jar /opt/${APP_NAME}.jar

# 赋权
RUN chmod +x /opt/${APP_NAME}.jar

# 默认入口
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
