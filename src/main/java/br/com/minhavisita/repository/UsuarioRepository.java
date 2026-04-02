package br.com.minhavisita.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.minhavisita.domain.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
  Optional<Usuario> findByEmail(String email);
}
