package com.relatosdepapel.bookspayments.payment;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService service;

    public PaymentController(PaymentService service) {
        this.service = service;
    }

    @GetMapping
    public List<Payment> getAll(@RequestParam(required = false) String buyerEmail) {
        if (buyerEmail != null && !buyerEmail.isBlank()) {
            return service.findByBuyerEmail(buyerEmail);
        }
        return service.findAll();
    }

    @GetMapping("/{id}")
    public Payment getById(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Payment create(@RequestBody @Valid PaymentRequest req) {
        return service.create(req);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }

    @PatchMapping("/{id}/status")
    @ResponseStatus(HttpStatus.OK)
    public Payment updateStatus(@PathVariable Long id, @RequestBody @Valid PaymentStatusRequest req) {
        return service.updateStatus(id, req.getStatus());
    }
}
