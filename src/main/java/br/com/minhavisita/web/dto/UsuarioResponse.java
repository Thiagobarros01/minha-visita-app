package br.com.minhavisita.web.dto;

public record UsuarioResponse(
    Long id,
    String nome,
    String email
) {}
