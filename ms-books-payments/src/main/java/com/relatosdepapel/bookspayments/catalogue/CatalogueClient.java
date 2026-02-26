package com.relatosdepapel.bookspayments.catalogue;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class CatalogueClient {

    private final RestTemplate restTemplate;

    public CatalogueClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public BookDto getBookById(Long id) {
        // Llamada por nombre de servicio en Eureka
        String url = "http://ms-books-catalogue/api/books/" + id;
        return restTemplate.getForObject(url, BookDto.class);
    }
}
