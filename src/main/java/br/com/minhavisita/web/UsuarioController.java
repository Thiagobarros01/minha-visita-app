package br.com.minhavisita.web;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import br.com.minhavisita.domain.PerfilUsuario;
import br.com.minhavisita.domain.Usuario;
import br.com.minhavisita.service.UsuarioService;
import br.com.minhavisita.web.dto.CreateUsuarioRequest;
import br.com.minhavisita.web.dto.UsuarioResponse;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/usuarios")
@Validated
public class UsuarioController {
  private final UsuarioService usuarioService;

  public UsuarioController(UsuarioService usuarioService) {
    this.usuarioService = usuarioService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public UsuarioResponse criar(@Valid @RequestBody CreateUsuarioRequest request) {
    Usuario usuario = new Usuario();
    usuario.setNome(request.nome());
    usuario.setEmail(request.email());
    usuario.setPerfil(request.perfil() == null ? PerfilUsuario.OPERADOR : request.perfil());
    return toResponse(usuarioService.criar(usuario, request.senha()));
  }

  @GetMapping
  public List<UsuarioResponse> listar() {
    return usuarioService.listar().stream().map(this::toResponse).toList();
  }

  private UsuarioResponse toResponse(Usuario usuario) {
    return new UsuarioResponse(usuario.getId(), usuario.getNome(), usuario.getEmail(), usuario.getPerfil());
  }
}
