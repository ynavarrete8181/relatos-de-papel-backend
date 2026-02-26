package com.relatosdepapel.bookscatalogue.book;

import org.springframework.data.jpa.domain.Specification;
import java.time.LocalDate;

public final class BookSpecifications {

    private BookSpecifications() {
    }

    public static Specification<Book> titleContains(String title) {
        return (root, query, cb) -> cb.like(cb.lower(root.get("title")), "%" + title.toLowerCase() + "%");
    }

    public static Specification<Book> authorContains(String author) {
        return (root, query, cb) -> cb.like(cb.lower(root.get("author")), "%" + author.toLowerCase() + "%");
    }

    public static Specification<Book> publicationDateEquals(LocalDate date) {
        return (root, query, cb) -> cb.equal(root.get("publicationDate"), date);
    }

    public static Specification<Book> categoryEquals(String category) {
        return (root, query, cb) -> cb.equal(cb.lower(root.get("category")), category.toLowerCase());
    }

    public static Specification<Book> isbnEquals(String isbn) {
        return (root, query, cb) -> cb.equal(root.get("isbn"), isbn);
    }

    public static Specification<Book> ratingEquals(Integer rating) {
        return (root, query, cb) -> cb.equal(root.get("rating"), rating);
    }

    public static Specification<Book> visibleEquals(Boolean visible) {
        return (root, query, cb) -> cb.equal(root.get("visible"), visible);
    }
}
