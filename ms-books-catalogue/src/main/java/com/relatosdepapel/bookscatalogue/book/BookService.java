package com.relatosdepapel.bookscatalogue.book;

import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class BookService {

    private final BookRepository repo;

    public BookService(BookRepository repo) {
        this.repo = repo;
    }

    public List<Book> findAll() {
        return repo.findAll();
    }

    public Book findById(Long id) {
        return repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Book not found: " + id));
    }

    public Book create(Book book) {
        book.setId(null); // IMPORTANTE
        return repo.save(book);
    }

    public Book update(Long id, Book book) {
        Book existing = findById(id);

        existing.setTitle(book.getTitle());
        existing.setAuthor(book.getAuthor());
        existing.setPrice(book.getPrice());
        existing.setCover(book.getCover());
        existing.setDescription(book.getDescription());

        // ✅ nuevos campos
        existing.setPublicationDate(book.getPublicationDate());
        existing.setCategory(book.getCategory());
        existing.setIsbn(book.getIsbn());
        existing.setRating(book.getRating());
        existing.setVisible(book.getVisible());

        return repo.save(existing);
    }

    @Transactional
    public Book patch(Long id, Book partial) {
        Book existing = findById(id);

        if (partial.getTitle() != null)
            existing.setTitle(partial.getTitle());
        if (partial.getAuthor() != null)
            existing.setAuthor(partial.getAuthor());
        if (partial.getPrice() != null)
            existing.setPrice(partial.getPrice());
        if (partial.getCover() != null)
            existing.setCover(partial.getCover());
        if (partial.getDescription() != null)
            existing.setDescription(partial.getDescription());

        // ✅ nuevos campos
        if (partial.getPublicationDate() != null)
            existing.setPublicationDate(partial.getPublicationDate());
        if (partial.getCategory() != null)
            existing.setCategory(partial.getCategory());
        if (partial.getIsbn() != null)
            existing.setIsbn(partial.getIsbn());
        if (partial.getRating() != null)
            existing.setRating(partial.getRating());
        if (partial.getVisible() != null)
            existing.setVisible(partial.getVisible());

        return existing; // por @Transactional
    }

    public void delete(Long id) {
        if (!repo.existsById(id)) {
            throw new RuntimeException("Book not found: " + id);
        }
        repo.deleteById(id);
    }

    public List<Book> search(
            String title,
            String author,
            LocalDate publicationDate,
            String category,
            String isbn,
            Integer rating,
            Boolean visible) {
        Specification<Book> spec = Specification.where(null);

        if (title != null && !title.isBlank())
            spec = spec.and(BookSpecifications.titleContains(title));

        if (author != null && !author.isBlank())
            spec = spec.and(BookSpecifications.authorContains(author));

        if (publicationDate != null)
            spec = spec.and(BookSpecifications.publicationDateEquals(publicationDate));

        if (category != null && !category.isBlank())
            spec = spec.and(BookSpecifications.categoryEquals(category));

        if (isbn != null && !isbn.isBlank())
            spec = spec.and(BookSpecifications.isbnEquals(isbn));

        if (rating != null)
            spec = spec.and(BookSpecifications.ratingEquals(rating));

        // ✅ por defecto: NO mostrar ocultos
        if (visible == null)
            spec = spec.and(BookSpecifications.visibleEquals(true));
        else
            spec = spec.and(BookSpecifications.visibleEquals(visible));

        return repo.findAll(spec);
    }
}
