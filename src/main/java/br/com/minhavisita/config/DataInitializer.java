package br.com.minhavisita.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import br.com.minhavisita.domain.PerfilUsuario;
import br.com.minhavisita.domain.Usuario;
import br.com.minhavisita.repository.UsuarioRepository;
import br.com.minhavisita.service.UsuarioService;

@Configuration
public class DataInitializer {
  @Bean
  CommandLineRunner seedAdmin(UsuarioRepository usuarioRepository, UsuarioService usuarioService) {
    return args -> {
      String emailAdmin = "admin@admin.com";

      usuarioRepository.findByEmail(emailAdmin).ifPresentOrElse(usuario -> {
        usuario.setPerfil(PerfilUsuario.ADMIN);
        usuarioRepository.save(usuario);
      }, () -> {
        Usuario usuario = new Usuario();
        usuario.setNome("Admin");
        usuario.setEmail(emailAdmin);
        usuario.setPerfil(PerfilUsuario.ADMIN);
        usuarioService.criar(usuario, "123");
      });
    };
  }
}