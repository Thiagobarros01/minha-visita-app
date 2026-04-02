package br.com.minhavisita.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.minhavisita.domain.Checkin;

public interface CheckinRepository extends JpaRepository<Checkin, Long> {
  Optional<Checkin> findByVisitaIdAndDataCheckoutIsNull(Long visitaId);
}
