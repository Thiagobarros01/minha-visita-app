package br.com.minhavisita.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;

import br.com.minhavisita.domain.PerfilUsuario;
import br.com.minhavisita.domain.Usuario;
import br.com.minhavisita.repository.UsuarioRepository;

@Service
public class UsuarioService {
  private final UsuarioRepository usuarioRepository;
  private final PasswordEncoder passwordEncoder;

  public UsuarioService(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
    this.usuarioRepository = usuarioRepository;
    this.passwordEncoder = passwordEncoder;
  }

  public Usuario criar(Usuario usuario, String senha) {
    if (usuario.getPerfil() == null) {
      usuario.setPerfil(PerfilUsuario.OPERADOR);
    }
    usuario.setSenhaHash(passwordEncoder.encode(senha));
    return usuarioRepository.save(usuario);
  }

  public List<Usuario> listar() {
    return usuarioRepository.findAll();
  }

  public List<Usuario> listarOperadores() {
    return usuarioRepository.findAll().stream()
        .filter(usuario -> usuario.getPerfil() == PerfilUsuario.OPERADOR)
        .toList();
  }

  public Usuario buscar(Long id) {
    return usuarioRepository.findById(id)
        .orElseThrow(() -> new NotFoundException("Usuario nao encontrado"));
  }

  public Usuario buscarPorEmail(String email) {
    return usuarioRepository.findByEmail(email)
        .orElseThrow(() -> new NotFoundException("Usuario nao encontrado"));
  }

  public boolean validarSenha(Usuario usuario, String senha) {
    return passwordEncoder.matches(senha, usuario.getSenhaHash());
  }
}
