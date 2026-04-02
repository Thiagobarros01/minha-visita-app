package br.com.minhavisita.repository;

import java.time.OffsetDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.minhavisita.domain.Visita;

public interface VisitaRepository extends JpaRepository<Visita, Long> {
  List<Visita> findByUsuarioIdAndDataAgendadaBetween(Long usuarioId, OffsetDateTime inicio, OffsetDateTime fim);
}
