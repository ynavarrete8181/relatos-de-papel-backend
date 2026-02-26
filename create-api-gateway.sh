#!/usr/bin/env bash
set -euo pipefail

# Debes ejecutar esto desde la raíz del repo: relatos-de-papel-backend
ROOT="$(pwd)"

echo "📌 Root: $ROOT"

# Borra si quedó algo vacío o a medias
rm -rf api-gateway

# Crea carpeta base
mkdir -p api-gateway
cd api-gateway

# Copia el Maven Wrapper desde eureka-server (para tener ./mvnw)
cp ../eureka-server/mvnw . 2>/dev/null || true
cp ../eureka-server/mvnw.cmd . 2>/dev/null || true
cp -R ../eureka-server/.mvn . 2>/dev/null || true
chmod +x mvnw 2>/dev/null || true

# Estructura
mkdir -p src/main/java/com/relatosdepapel/apigateway
mkdir -p src/main/resources
mkdir -p src/test/java/com/relatosdepapel/apigateway

# pom.xml (Gateway = WebFlux, NO usar spring-boot-starter-web)
cat > pom.xml <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.12</version>
    <relativePath/>
  </parent>

  <groupId>com.relatosdepapel</groupId>
  <artifactId>api-gateway</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>api-gateway</name>
  <description>API Gateway</description>

  <properties>
    <java.version>17</java.version>
    <spring-cloud.version>2023.0.5</spring-cloud.version>
  </properties>

  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-dependencies</artifactId>
        <version>${spring-cloud.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>

  <dependencies>
    <!-- Spring Cloud Gateway (WebFlux) -->
    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-gateway</artifactId>
    </dependency>

    <!-- Eureka client -->
    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    </dependency>

    <!-- LoadBalancer para lb://SERVICE-ID -->
    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-loadbalancer</artifactId>
    </dependency>

    <!-- Actuator -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>

    <!-- Tests -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
XML

# Main app
cat > src/main/java/com/relatosdepapel/apigateway/ApiGatewayApplication.java <<'JAVA'
package com.relatosdepapel.apigateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
JAVA

# application.yml
cat > src/main/resources/application.yml <<'YML'
server:
  port: 8080

spring:
  application:
    name: api-gateway

  cloud:
    gateway:
      routes:
        - id: books-catalogue
          uri: lb://MS-BOOKS-CATALOGUE
          predicates:
            - Path=/api/books/**

        - id: books-payments
          uri: lb://MS-BOOKS-PAYMENTS
          predicates:
            - Path=/api/payments/**

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
    register-with-eureka: true
    fetch-registry: true

management:
  endpoints:
    web:
      exposure:
        include: health,info

logging:
  level:
    org.springframework.cloud.gateway: INFO
YML

# Test
cat > src/test/java/com/relatosdepapel/apigateway/ApiGatewayApplicationTests.java <<'JAVA'
package com.relatosdepapel.apigateway;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class ApiGatewayApplicationTests {
    @Test void contextLoads() {}
}
JAVA

echo "✅ api-gateway creado en: $(pwd)"
echo "📁 Contenido:"
ls -la
