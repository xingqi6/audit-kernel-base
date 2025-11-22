# 使用兼容性最好的 Java 8 环境 (SurveyKing v1.3.1 基于 Java 8)
FROM eclipse-temurin:8-jre-alpine

ENV APP_NAME=audit_core_module
WORKDIR /opt

# 安装 wget
RUN apk add --no-cache wget

# 1. 下载核心文件
# --tries=5: 失败重试5次
# -O: 指定保存文件名
RUN echo "Downloading Core Module..." && \
    wget --tries=5 --timeout=60 -O /opt/${APP_NAME}.jar \
    "https://github.com/javahuang/SurveyKing/releases/download/v1.3.1/survey-server.jar"

# 2. 关键步骤：验证文件是否损坏！
# SurveyKing 的包大约 46MB。如果小于 10MB，说明下载错了（如下载成了 HTML 页面）。
# 这里的逻辑是：检查文件大小，如果小于 10000KB (10MB)，直接退出报错 (exit 1)。
RUN FILE_SIZE=$(du -k /opt/${APP_NAME}.jar | cut -f1) && \
    echo "Downloaded file size: ${FILE_SIZE} KB" && \
    if [ "$FILE_SIZE" -lt 10000 ]; then \
        echo "❌ CRITICAL ERROR: File is too small! Download failed."; \
        exit 1; \
    else \
        echo "✅ File integrity check passed."; \
    fi

# 3. 赋权
RUN chmod +x /opt/${APP_NAME}.jar

# 4. 启动入口
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
