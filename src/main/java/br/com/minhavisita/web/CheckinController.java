package br.com.minhavisita.web;

import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import br.com.minhavisita.domain.Checkin;
import br.com.minhavisita.service.CheckinService;
import br.com.minhavisita.service.GeoUtils;
import br.com.minhavisita.web.dto.CheckinRequest;
import br.com.minhavisita.web.dto.CheckinResponse;
import br.com.minhavisita.web.dto.CheckoutRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/checkins")
@Validated
public class CheckinController {
  private final CheckinService checkinService;

  public CheckinController(CheckinService checkinService) {
    this.checkinService = checkinService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public CheckinResponse checkin(@Valid @RequestBody CheckinRequest request) {
    Checkin checkin = checkinService.realizarCheckin(
        request.visitaId(),
        request.latitude(),
        request.longitude(),
        request.dataHora()
    );
    return toResponse(checkin);
  }

  @PostMapping("/{id}/checkout")
  public CheckinResponse checkout(@PathVariable Long id, @Valid @RequestBody CheckoutRequest request) {
    Checkin checkin = checkinService.realizarCheckout(
        id,
        request.latitude(),
        request.longitude(),
        request.dataHora()
    );
    return toResponse(checkin);
  }

  private CheckinResponse toResponse(Checkin checkin) {
    double distancia = GeoUtils.distanciaMetros(
        checkin.getVisita().getLatitude(),
        checkin.getVisita().getLongitude(),
        checkin.getLatCheckin(),
        checkin.getLngCheckin()
    );
    return new CheckinResponse(
        checkin.getId(),
        checkin.getVisita().getId(),
        checkin.getDataCheckin(),
        checkin.getLatCheckin(),
        checkin.getLngCheckin(),
        checkin.getDataCheckout(),
        checkin.getLatCheckout(),
        checkin.getLngCheckout(),
        checkin.getDuracaoSegundos(),
        distancia
    );
  }
}
