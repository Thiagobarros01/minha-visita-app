package br.com.minhavisita.web.dto;

import java.time.OffsetDateTime;
import java.util.List;

public record JornadaResumoResponse(
    Long usuarioId,
    String nome,
    String email,
    Double latitudeAtual,
    Double longitudeAtual,
    Double kmPercorridos,
    OffsetDateTime atualizacaoEm,
    List<String> locaisVisitados,
    Integer totalLocaisVisitados
) {}