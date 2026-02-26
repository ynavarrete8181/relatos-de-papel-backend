package com.relatosdepapel.bookspayments.catalogue;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class CatalogueClient {

    private final RestClient rest;

    public CatalogueClient(RestClient.Builder builder) {
        // OJO: aquí usamos el NOMBRE del servicio (Eureka / LoadBalancer)
        this.rest = builder.baseUrl("http://ms-books-catalogue").build();
    }

    public BookDto getBookById(Long id) {
        return rest.get()
                .uri("/api/books/{id}", id)
                .retrieve()
                .body(BookDto.class);
    }
}
