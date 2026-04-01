package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;

import jakarta.validation.constraints.NotNull;

public record CheckoutRequest(
    @NotNull Double latitude,
    @NotNull Double longitude,
    OffsetDateTime dataHora
) {}
