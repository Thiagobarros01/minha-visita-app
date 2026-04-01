package br.com.minhavisita.web.dto;

public record LoginResponse(
    String token,
    UsuarioResponse usuario
) {}
