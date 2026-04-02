package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;

import jakarta.validation.constraints.NotNull;

public record JornadaPingRequest(
    @NotNull Long usuarioId,
    @NotNull Double latitude,
    @NotNull Double longitude,
    OffsetDateTime dataHora
) {}