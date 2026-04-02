package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;

public record JornadaRotaPontoResponse(
    Double latitude,
    Double longitude,
    OffsetDateTime dataHora
) {}