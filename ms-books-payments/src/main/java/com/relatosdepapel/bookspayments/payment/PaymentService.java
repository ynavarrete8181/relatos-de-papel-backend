package com.relatosdepapel.bookspayments.payment;

import com.relatosdepapel.bookspayments.catalogue.BookDto;
import com.relatosdepapel.bookspayments.catalogue.CatalogueClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class PaymentService {

    private final PaymentRepository repo;
    private final CatalogueClient catalogue;

    public PaymentService(PaymentRepository repo, CatalogueClient catalogue) {
        this.repo = repo;
        this.catalogue = catalogue;
    }

    public List<Payment> findAll() {
        return repo.findAll();
    }

    public Payment findById(Long id) {
        return repo.findById(id).orElseThrow(() -> new RuntimeException("Payment not found: " + id));
    }

    public List<Payment> findByBuyerEmail(String email) {
        return repo.findByBuyerEmailIgnoreCase(email);
    }

    @Transactional
    public Payment create(PaymentRequest req) {
        BookDto book = catalogue.getBookById(req.getBookId());

        if (book == null) {
            throw new RuntimeException("Book not found: " + req.getBookId());
        }
        if (Boolean.FALSE.equals(book.getVisible())) {
            throw new RuntimeException("Book is not visible: " + req.getBookId());
        }
        if (book.getPrice() == null) {
            throw new RuntimeException("Book price is null: " + req.getBookId());
        }

        BigDecimal unitPrice = book.getPrice();
        BigDecimal total = unitPrice.multiply(BigDecimal.valueOf(req.getQuantity()));

        Payment p = new Payment();
        p.setBookId(book.getId());
        p.setBookIsbn(book.getIsbn());
        p.setBookTitle(book.getTitle());
        p.setUnitPrice(unitPrice);
        p.setQuantity(req.getQuantity());
        p.setTotal(total);
        p.setBuyerEmail(req.getBuyerEmail());
        p.setStatus("CREATED");

        return repo.save(p);
    }

    public void delete(Long id) {
        if (!repo.existsById(id))
            throw new RuntimeException("Payment not found: " + id);
        repo.deleteById(id);
    }

    public Payment updateStatus(Long id, String status) {
        Payment p = findById(id);

        String normalized = status == null ? null : status.trim().toUpperCase();

        if (!"CREATED".equals(normalized) && !"PAID".equals(normalized) && !"CANCELLED".equals(normalized)) {
            throw new RuntimeException("Invalid status: " + status + ". Allowed: CREATED, PAID, CANCELLED");
        }

        p.setStatus(normalized);
        return p;
    }
}
