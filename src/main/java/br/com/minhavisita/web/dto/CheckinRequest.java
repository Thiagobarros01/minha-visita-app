package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;

import jakarta.validation.constraints.NotNull;

public record CheckinRequest(
    @NotNull Long visitaId,
    @NotNull Double latitude,
    @NotNull Double longitude,
    OffsetDateTime dataHora
) {}
