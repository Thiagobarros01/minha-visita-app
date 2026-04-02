package br.com.minhavisita.web.dto;

import br.com.minhavisita.domain.PerfilUsuario;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateUsuarioRequest(
    @NotBlank String nome,
    @NotBlank @Email String email,
    @NotBlank @Size(min = 3) String senha,
    PerfilUsuario perfil
) {}
