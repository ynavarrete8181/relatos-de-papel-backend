# ==========================================================
# Crea ms-books-payments COMPLETO (igual estilo que catalogue)
# DB: db_books_payments
# Puerto: 8083
# Eureka: http://localhost:8761/eureka
# ==========================================================

set -e

rm -rf ms-books-payments
mkdir -p ms-books-payments
cd ms-books-payments || exit 1

cp ../eureka-server/mvnw . 2>/dev/null || true
cp ../eureka-server/mvnw.cmd . 2>/dev/null || true
cp -R ../eureka-server/.mvn . 2>/dev/null || true
chmod +x mvnw 2>/dev/null || true

mkdir -p src/main/java/com/relatosdepapel/bookspayments
mkdir -p src/main/java/com/relatosdepapel/bookspayments/payment
mkdir -p src/main/java/com/relatosdepapel/bookspayments/catalogue
mkdir -p src/main/java/com/relatosdepapel/bookspayments/exception
mkdir -p src/main/resources/db/migration
mkdir -p src/test/java/com/relatosdepapel/bookspayments

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
  <artifactId>ms-books-payments</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>ms-books-payments</name>
  <description>Books Payments Service</description>

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
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>

    <dependency>
      <groupId>org.flywaydb</groupId>
      <artifactId>flyway-core</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-loadbalancer</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>

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

cat > src/main/java/com/relatosdepapel/bookspayments/MsBooksPaymentsApplication.java <<'JAVA'
package com.relatosdepapel.bookspayments;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MsBooksPaymentsApplication {
    public static void main(String[] args) {
        SpringApplication.run(MsBooksPaymentsApplication.class, args);
    }
}
JAVA

cat > src/main/resources/application.yml <<'YML'
server:
  port: 8083

spring:
  application:
    name: ms-books-payments

  datasource:
    url: jdbc:postgresql://localhost:5432/db_books_payments
    username: postgres
    password: postgres

  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

  flyway:
    enabled: true
    locations: classpath:db/migration

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
    register-with-eureka: true
    fetch-registry: true
YML

cat > src/main/resources/db/migration/V1__init.sql <<'SQL'
CREATE TABLE IF NOT EXISTS public.purchases (
  id BIGSERIAL PRIMARY KEY,
  buyer_email VARCHAR(255),
  total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.purchase_items (
  id BIGSERIAL PRIMARY KEY,
  purchase_id BIGINT NOT NULL,
  book_id BIGINT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  line_total NUMERIC(10,2) NOT NULL CHECK (line_total >= 0),
  CONSTRAINT fk_purchase_items_purchase
    FOREIGN KEY (purchase_id)
    REFERENCES public.purchases(id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase_id
  ON public.purchase_items(purchase_id);

CREATE INDEX IF NOT EXISTS idx_purchase_items_book_id
  ON public.purchase_items(book_id);

CREATE INDEX IF NOT EXISTS idx_purchases_created_at
  ON public.purchases(created_at);
SQL

cat > src/main/java/com/relatosdepapel/bookspayments/catalogue/BookDto.java <<'JAVA'
package com.relatosdepapel.bookspayments.catalogue;

import java.math.BigDecimal;

public class BookDto {
    public Long id;
    public String title;
    public String author;
    public BigDecimal price;
    public Boolean visible;
}
JAVA

cat > src/main/java/com/relatosdepapel/bookspayments/catalogue/CatalogueClientConfig.java <<'JAVA'
package com.relatosdepapel.bookspayments.catalogue;

import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class CatalogueClientConfig {

    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
JAVA

cat > src/main/java/com/relatosdepapel/bookspayments/payment/Purchase.java <<'JAVA'
package com.relatosdepapel.bookspayments.payment;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "purchases")
public class Purchase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String buyerEmail;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal total;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "purchase", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PurchaseItem> items = new ArrayList<>();

    public Purchase() {}

    public void addItem(PurchaseItem item) {
        item.setPurchase(this);
        this.items.add(item);
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getBuyerEmail() { return buyerEmail; }
    public void setBuyerEmail(String buyerEmail) { this.buyerEmail = buyerEmail; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<PurchaseItem> getItems() { return items; }
    public void setItems(List<PurchaseItem> items) { this.items = items; }
}
JAVA

cat > src/main/java/com/relatosdepapel/bookspayments/payment/PurchaseItem.java <<'JAVA'
package com.relatosdepapel.bookspayments.payment;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "purchase_items")
public class PurchaseItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "purchase_id")
    private Purchase purchase;

    @Column(nullable = false)
    private Long bookId;

    @Column(nullable = false)
    private Integer quantity;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal lineTotal;

    public PurchaseItem() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Purchase getPurchase() { return purchase; }
    public void setPurchase(Purchase purchase) { this.purchase = purchase; }

    public Long getBookId() { return bookId; }
    public void setBookId(Long bookId) { this.bookId = bookId; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getLineTotal() { return lineTotal; }
    public void setLineTotal(BigDecimal lineTotal) { this.lineTotal = lineTotal; }
}
JAVA

cat > src/main/java/com/relatosdepapel/bookspayments/payment/PurchaseRepository.java <<'JAVA'
package com.relatosdepapel.bookspayments.payment;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PurchaseRepository extends JpaRepository<Purchase, Long> {
}
JAVA

cat > src/main/java/com/relatosdepapel/bookspayments/payment/PaymentService.java <<'JAVA'
package com.relatosdepapel.bookspayments.payment;

import com.relatosdepapel.bookspayments.catalogue.BookDto;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.List;

@Service
public class PaymentService {

    private final PurchaseRepository purchaseRepo;
    private final RestTemplate restTemplate;

    public PaymentService(PurchaseRepository purchaseRepo, RestTemplate restTemplate) {
        this.purchaseRepo = purchaseRepo;
        this.restTemplate = restTemplate;
    }

    @Transactional
    public Purchase createPurchase(String buyerEmail, List<ItemRequest> items) {
        if (items == null || items.isEmpty()) {
            throw new IllegalArgumentException("items is required");
        }

        Purchase purchase = new Purchase();
        purchase.setBuyerEmail(buyerEmail);

        BigDecimal total = BigDecimal.ZERO;

        for (ItemRequest item : items) {
            if (item.bookId == null || item.quantity == null || item.quantity <= 0) {
                throw new IllegalArgumentException("Invalid item: bookId and quantity > 0 required");
            }

            BookDto book = getBookOrFail(item.bookId);

            if (book.visible != null && !book.visible) {
                throw new IllegalArgumentException("Book is hidden: " + item.bookId);
            }

            BigDecimal unitPrice = book.price;
            BigDecimal lineTotal = unitPrice.multiply(BigDecimal.valueOf(item.quantity));

            PurchaseItem pi = new PurchaseItem();
            pi.setBookId(item.bookId);
            pi.setQuantity(item.quantity);
            pi.setUnitPrice(unitPrice);
            pi.setLineTotal(lineTotal);

            purchase.addItem(pi);
            total = total.add(lineTotal);
        }

        purchase.setTotal(total);
        return purchaseRepo.save(purchase);
    }

    public Purchase findById(Long id) {
        return purchaseRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Purchase not found: " + id));
    }

    private BookDto getBookOrFail(Long bookId) {
        try {
            return restTemplate.getForObject(
                    "http://ms-books-catalogue/api/books/{id}",
                    BookDto.class,
                    bookId
            );
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.NOT_FOUND) {
                throw new IllegalArgumentException("Book not found: " + bookId);
            }
            throw e;
        }
    }

    public static class ItemRequest {
        public Long bookId;
        public Integer quantity;
    }
}
JAVA

cat > src/main/java/com/relatosdepapel/bookspayments/payment/PaymentController.java <<'JAVA'
package com.relatosdepapel.bookspayments.payment;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/purchases")
public class PaymentController {

    private final PaymentService service;

    public PaymentController(PaymentService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Purchase create(@RequestBody CreatePurchaseRequest request) {
        return service.createPurchase(request.buyerEmail, toInternalItems(request.items));
    }

    @GetMapping("/{id}")
    public Purchase getById(@PathVariable Long id) {
        return service.findById(id);
    }

    private List<PaymentService.ItemRequest> toInternalItems(List<Item> items) {
        return items.stream().map(i -> {
            PaymentService.ItemRequest r = new PaymentService.ItemRequest();
            r.bookId = i.bookId;
            r.quantity = i.quantity;
            return r;
        }).toList();
    }

    public static class CreatePurchaseRequest {
        @Email
        public String buyerEmail;

        @NotEmpty
        public List<Item> items;
    }

    public static class Item {
        @NotNull
        public Long bookId;

        @NotNull
        @Positive
        public Integer quantity;
    }
}
JAVA

cat > src/test/java/com/relatosdepapel/bookspayments/MsBooksPaymentsApplicationTests.java <<'JAVA'
package com.relatosdepapel.bookspayments;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class MsBooksPaymentsApplicationTests {
    @Test void contextLoads() {}
}
JAVA

echo "✅ Proyecto creado en: $(pwd)"
echo "📁 Contenido:"
ls
