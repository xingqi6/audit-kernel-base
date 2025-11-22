FROM eclipse-temurin:8-jre-alpine

# 瀹氫箟浼鍚嶇О
ENV APP_NAME=audit_core_module

# 涓嬭浇鏍稿績鏂囦欢 -> 閲嶅懡鍚嶄负 audit_core.jar -> 娓呯悊
# 娉ㄦ剰锛氳繖閲屼娇鐢ㄤ簡 SurveyKing 鐨� Release 閾炬帴锛屼絾鍦ㄦ瀯寤哄悗锛岄暅鍍忓唴鍙湁 audit_core.jar锛屾棤鏉ユ簮淇℃伅
RUN apk add --no-cache curl && \
    curl -L https://github.com/javahuang/SurveyKing/releases/download/v1.3.1/survey-server.jar -o /opt/${APP_NAME}.jar && \
    chmod +x /opt/${APP_NAME}.jar && \
    apk del curl

# 璁剧疆宸ヤ綔鐩綍
WORKDIR /opt

# 榛樿鍏ュ彛锛堝悗缁細鍦� HF 涓瑕嗙洊锛屼絾杩欓噷鐣欎竴涓粯璁ゅ€硷級
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
