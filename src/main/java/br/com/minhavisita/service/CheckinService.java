package br.com.minhavisita.service;

import java.time.Duration;
import java.time.OffsetDateTime;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.minhavisita.domain.Checkin;
import br.com.minhavisita.domain.Visita;
import br.com.minhavisita.domain.VisitaStatus;
import br.com.minhavisita.repository.CheckinRepository;

@Service
public class CheckinService {
  private final CheckinRepository checkinRepository;
  private final VisitaService visitaService;

  public CheckinService(CheckinRepository checkinRepository, VisitaService visitaService) {
    this.checkinRepository = checkinRepository;
    this.visitaService = visitaService;
  }

  @Transactional
  public Checkin realizarCheckin(Long visitaId, Double latitude, Double longitude, OffsetDateTime dataHora) {
    if (latitude == null || longitude == null) {
      throw new BadRequestException("Latitude e longitude sao obrigatorias");
    }

    Visita visita = visitaService.buscar(visitaId);

    if (checkinRepository.findByVisitaIdAndDataCheckoutIsNull(visitaId).isPresent()) {
      throw new BadRequestException("Ja existe check-in aberto para esta visita");
    }

    validarDistancia(visita, latitude, longitude);

    Checkin checkin = new Checkin();
    checkin.setVisita(visita);
    checkin.setDataCheckin(dataHora != null ? dataHora : OffsetDateTime.now());
    checkin.setLatCheckin(latitude);
    checkin.setLngCheckin(longitude);

    visita.setStatus(VisitaStatus.EM_ANDAMENTO);
    visitaService.salvar(visita);

    return checkinRepository.save(checkin);
  }

  @Transactional
  public Checkin realizarCheckout(Long checkinId, Double latitude, Double longitude, OffsetDateTime dataHora) {
    if (latitude == null || longitude == null) {
      throw new BadRequestException("Latitude e longitude sao obrigatorias");
    }

    Checkin checkin = checkinRepository.findById(checkinId)
        .orElseThrow(() -> new NotFoundException("Check-in nao encontrado"));

    if (checkin.getDataCheckout() != null) {
      throw new BadRequestException("Check-out ja realizado");
    }

    Visita visita = checkin.getVisita();

    OffsetDateTime checkoutTime = dataHora != null ? dataHora : OffsetDateTime.now();
    checkin.setDataCheckout(checkoutTime);
    checkin.setLatCheckout(latitude);
    checkin.setLngCheckout(longitude);
    long duracao = Duration.between(checkin.getDataCheckin(), checkoutTime).getSeconds();
    checkin.setDuracaoSegundos(Math.max(duracao, 0));

    visita.setStatus(VisitaStatus.CONCLUIDA);
    visitaService.salvar(visita);

    return checkinRepository.save(checkin);
  }

  private void validarDistancia(Visita visita, double latitude, double longitude) {
    double distancia = GeoUtils.distanciaMetros(visita.getLatitude(), visita.getLongitude(), latitude, longitude);
    int raio = visita.getRaioMetros() != null ? visita.getRaioMetros() : 100;
    if (distancia > raio) {
      throw new BadRequestException("Fora do raio permitido da visita");
    }
  }
}
