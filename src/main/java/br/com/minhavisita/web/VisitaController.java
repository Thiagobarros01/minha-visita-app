package br.com.minhavisita.web;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import br.com.minhavisita.domain.Visita;
import br.com.minhavisita.service.VisitaService;
import br.com.minhavisita.web.dto.CreateVisitaRequest;
import br.com.minhavisita.web.dto.VisitaResponse;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/visitas")
@Validated
public class VisitaController {
  private final VisitaService visitaService;

  public VisitaController(VisitaService visitaService) {
    this.visitaService = visitaService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public VisitaResponse criar(@Valid @RequestBody CreateVisitaRequest request) {
    Visita visita = new Visita();
    visita.setClienteNome(request.clienteNome());
    visita.setEndereco(request.endereco());
    visita.setLatitude(request.latitude());
    visita.setLongitude(request.longitude());
    visita.setDataAgendada(request.dataAgendada());
    visita.setRaioMetros(request.raioMetros());

    return toResponse(visitaService.criar(visita, request.usuarioId()));
  }

  @GetMapping("/{id}")
  public VisitaResponse buscar(@PathVariable Long id) {
    return toResponse(visitaService.buscar(id));
  }

  @GetMapping
  public List<VisitaResponse> listarPorUsuarioEDia(
      @RequestParam Long usuarioId,
      @RequestParam LocalDate data
  ) {
    return visitaService.listarPorUsuarioEDia(usuarioId, data).stream().map(this::toResponse).toList();
  }

  private VisitaResponse toResponse(Visita visita) {
    return new VisitaResponse(
        visita.getId(),
        visita.getUsuario().getId(),
        visita.getClienteNome(),
        visita.getEndereco(),
        visita.getLatitude(),
        visita.getLongitude(),
        visita.getDataAgendada(),
        visita.getRaioMetros(),
        visita.getStatus()
    );
  }
}
