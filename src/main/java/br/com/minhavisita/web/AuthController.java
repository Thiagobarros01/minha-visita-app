package br.com.minhavisita.web;

import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.minhavisita.domain.Usuario;
import br.com.minhavisita.service.AuthService;
import br.com.minhavisita.service.UsuarioService;
import br.com.minhavisita.web.dto.LoginRequest;
import br.com.minhavisita.web.dto.LoginResponse;
import br.com.minhavisita.web.dto.UsuarioResponse;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
@Validated
public class AuthController {
  private final AuthService authService;
  private final UsuarioService usuarioService;

  public AuthController(AuthService authService, UsuarioService usuarioService) {
    this.authService = authService;
    this.usuarioService = usuarioService;
  }

  @PostMapping("/login")
  public LoginResponse login(@Valid @RequestBody LoginRequest request) {
    String token = authService.login(request.email(), request.senha());
    Usuario usuario = usuarioService.buscarPorEmail(request.email());
    UsuarioResponse usuarioResponse = new UsuarioResponse(
        usuario.getId(),
        usuario.getNome(),
        usuario.getEmail(),
        usuario.getPerfil());
    return new LoginResponse(token, usuarioResponse);
  }
}
