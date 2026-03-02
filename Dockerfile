# syntax=docker/dockerfile:1

FROM gradle:8.10.2-jdk17 AS builder
WORKDIR /app

COPY gradle ./gradle
COPY gradlew gradlew.bat build.gradle settings.gradle ./

# Resolve and cache Gradle dependencies in a separate layer to speed repeated builds.
RUN chmod +x ./gradlew && ./gradlew dependencies --no-daemon

COPY src ./src

# Avoid 'clean' to keep Docker layer cache effective across deployments.
RUN ./gradlew bootJar -x test --no-daemon

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

ENV SPRING_PROFILES_ACTIVE=production
EXPOSE 8080

CMD ["sh", "-c", "java -jar app.jar --server.port=${PORT:-8080}"]
