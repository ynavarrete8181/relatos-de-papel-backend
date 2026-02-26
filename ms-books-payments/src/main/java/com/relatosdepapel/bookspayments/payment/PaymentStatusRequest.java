package com.relatosdepapel.bookspayments.payment;

import jakarta.validation.constraints.NotBlank;

public class PaymentStatusRequest {

    @NotBlank
    private String status;

    public PaymentStatusRequest() {
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
