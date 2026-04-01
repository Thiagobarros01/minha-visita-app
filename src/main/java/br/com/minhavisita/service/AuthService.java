package br.com.minhavisita.service;

import java.util.UUID;

import org.springframework.stereotype.Service;

import br.com.minhavisita.domain.Usuario;

@Service
public class AuthService {
  private final UsuarioService usuarioService;

  public AuthService(UsuarioService usuarioService) {
    this.usuarioService = usuarioService;
  }

  public String login(String email, String senha) {
    try {
      Usuario usuario = usuarioService.buscarPorEmail(email);
      if (!usuarioService.validarSenha(usuario, senha)) {
        throw new UnauthorizedException("Credenciais invalidas");
      }
      return UUID.randomUUID().toString();
    } catch (NotFoundException ex) {
      throw new UnauthorizedException("Credenciais invalidas");
    }
  }
}
