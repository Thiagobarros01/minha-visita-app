package br.com.minhavisita.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.minhavisita.domain.JornadaPonto;

public interface JornadaPontoRepository extends JpaRepository<JornadaPonto, Long> {
  List<JornadaPonto> findByJornadaDiaIdOrderByDataHoraAsc(Long jornadaDiaId);

  long countByJornadaDiaId(Long jornadaDiaId);

  Optional<JornadaPonto> findTop1ByJornadaDiaIdOrderByDataHoraAsc(Long jornadaDiaId);
}
