package com.relatosdepapel.bookscatalogue.book;

import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final BookService service;

    public BookController(BookService service) {
        this.service = service;
    }

    @GetMapping
    public List<Book> getAllOrSearch(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String author,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate publicationDate,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String isbn,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) Boolean visible) {

        boolean noFilters = (title == null || title.isBlank()) &&
                (author == null || author.isBlank()) &&
                publicationDate == null &&
                (category == null || category.isBlank()) &&
                (isbn == null || isbn.isBlank()) &&
                rating == null &&
                visible == null;

        if (noFilters) {
            return service.findAll(); // o findAllVisible() si quieres solo visibles
        }

        return service.search(title, author, publicationDate, category, isbn, rating, visible);
    }

    @GetMapping("/{id}")
    public Book getById(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Book create(@RequestBody @Valid Book book) {
        return service.create(book);
    }

    @PutMapping("/{id}")
    public Book update(@PathVariable Long id, @RequestBody @Valid Book book) {
        return service.update(id, book);
    }

    @PatchMapping("/{id}")
    public Book patch(@PathVariable Long id, @RequestBody Book book) {
        return service.patch(id, book);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
