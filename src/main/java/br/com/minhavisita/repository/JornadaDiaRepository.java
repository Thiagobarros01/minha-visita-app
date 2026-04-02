package br.com.minhavisita.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.minhavisita.domain.JornadaDia;

public interface JornadaDiaRepository extends JpaRepository<JornadaDia, Long> {
  Optional<JornadaDia> findByUsuarioIdAndDia(Long usuarioId, LocalDate dia);

  List<JornadaDia> findByDia(LocalDate dia);
}
