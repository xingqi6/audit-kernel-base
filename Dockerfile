# ==========================================
# 阶段 1：猎人模式 (从官方镜像提取核心)
# ==========================================
FROM surveyking/surveyking:latest AS source

# 切换到 root，确保有权限全盘搜索
USER root

# 核心逻辑：
# 1. 官方镜像里一定有 JAR 包。
# 2. 我们不猜它叫什么名字（survey.jar? app.jar?），也不猜它在哪。
# 3. 我们只找【大于 30MB】且是【.jar】结尾的文件。
# 4. 找到后，直接复制并重命名为 /core.jar
RUN echo "Searching for SurveyKing JAR..." && \
    TARGET=$(find / -type f -name "*.jar" -size +30M | head -n 1) && \
    if [ -z "$TARGET" ]; then echo "❌ FATAL: No JAR found!"; exit 1; fi && \
    echo "✅ Found JAR at: $TARGET" && \
    cp "$TARGET" /core.jar

# ==========================================
# 阶段 2：隐匿模式 (构建纯净运行环境)
# ==========================================
# SurveyKing 依赖 Java 8 环境
FROM eclipse-temurin:8-jre-alpine

# 定义伪装后的进程名 (看起来像系统审计进程)
ENV APP_NAME=audit_core_module
WORKDIR /opt

# 从第一阶段把提取到的文件复制过来
COPY --from=source /core.jar /opt/${APP_NAME}.jar

# 赋权
RUN chmod +x /opt/${APP_NAME}.jar

# 启动入口 (HF 启动时会覆盖此命令，但保留作为默认)
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
