package br.com.minhavisita.web.dto;

import br.com.minhavisita.domain.PerfilUsuario;

public record UsuarioResponse(
    Long id,
    String nome,
    String email,
    PerfilUsuario perfil
) {}
