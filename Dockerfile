# ==========================================
# 阶段 1：猎人模式 (从官方镜像提取核心)
# ==========================================
FROM surveyking/surveyking:latest AS source
USER root
# 提取核心 Jar 包
RUN find / -type f -name "*.jar" -size +30M -exec cp {} /core.jar \; || true

# ==========================================
# 阶段 2：稳定模式 (基于 Ubuntu，不再用 Alpine)
# ==========================================
# ⚠️ 关键修改：去掉 "-alpine" 后缀，使用标准版镜像
# 标准版内置了字体库和 glibc，解决了验证码和数据库崩溃的问题
FROM eclipse-temurin:8-jre

ENV APP_NAME=audit_core_module
WORKDIR /opt

# 从第一阶段复制文件
COPY --from=source /core.jar /opt/${APP_NAME}.jar

# 赋权
RUN chmod +x /opt/${APP_NAME}.jar

# 默认入口
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
