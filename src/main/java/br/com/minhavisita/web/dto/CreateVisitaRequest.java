package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record CreateVisitaRequest(
    @NotNull Long usuarioId,
    @NotBlank String clienteNome,
    @NotBlank String endereco,
    @NotNull Double latitude,
    @NotNull Double longitude,
    @NotNull OffsetDateTime dataAgendada,
    @Positive Integer raioMetros
) {}
