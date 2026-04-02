package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;

import br.com.minhavisita.domain.VisitaStatus;

public record VisitaResponse(
    Long id,
    Long usuarioId,
    String clienteNome,
    String endereco,
    Double latitude,
    Double longitude,
    OffsetDateTime dataAgendada,
    Integer raioMetros,
    VisitaStatus status
) {}
