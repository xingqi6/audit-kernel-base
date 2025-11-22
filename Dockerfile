# ==========================================
# 阶段 1：猎人模式 (从官方镜像提取核心)
# ==========================================
FROM surveyking/surveyking:latest AS source

# 切换到 root 权限，确保能搜索所有角落
USER root

# 核心逻辑：
# 1. find / : 全盘搜索
# 2. -name "*.jar" : 找 jar 包
# 3. -size +30M : 关键！只找大于 30MB 的文件 (排除掉小的依赖包)
# 4. -exec cp ... : 找到后直接复制并重命名为 /final.jar
# 5. || true : 防止某些目录没有权限报错导致构建停止
RUN find / -type f -name "*.jar" -size +30M -exec cp {} /final.jar \; || true

# 调试：打印一下我们找到了什么 (在 GitHub Actions 日志里能看到)
RUN ls -lh /final.jar

# ==========================================
# 阶段 2：伪装模式 (构建纯净运行环境)
# ==========================================
# SurveyKing 推荐使用 Java 8
FROM eclipse-temurin:8-jre-alpine

ENV APP_NAME=audit_core_module
WORKDIR /opt

# 从第一阶段把那个大于 30MB 的文件复制过来
COPY --from=source /final.jar /opt/${APP_NAME}.jar

# 赋权
RUN chmod +x /opt/${APP_NAME}.jar

# 启动
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
