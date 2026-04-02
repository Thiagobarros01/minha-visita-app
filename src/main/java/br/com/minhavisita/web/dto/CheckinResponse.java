package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;

public record CheckinResponse(
    Long id,
    Long visitaId,
    OffsetDateTime dataCheckin,
    Double latCheckin,
    Double lngCheckin,
    OffsetDateTime dataCheckout,
    Double latCheckout,
    Double lngCheckout,
    Long duracaoSegundos,
    Double distanciaMetros
) {}
