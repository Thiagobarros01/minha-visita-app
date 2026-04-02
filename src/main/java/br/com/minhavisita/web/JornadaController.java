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

import br.com.minhavisita.service.JornadaTrackingService;
import br.com.minhavisita.web.dto.JornadaPingRequest;
import br.com.minhavisita.web.dto.JornadaResumoResponse;
import br.com.minhavisita.web.dto.JornadaRotaPontoResponse;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/jornadas")
@Validated
public class JornadaController {
  private final JornadaTrackingService jornadaTrackingService;

  public JornadaController(JornadaTrackingService jornadaTrackingService) {
    this.jornadaTrackingService = jornadaTrackingService;
  }

  @PostMapping("/ping")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void ping(@Valid @RequestBody JornadaPingRequest request) {
    jornadaTrackingService.registrarPing(
        request.usuarioId(),
        request.latitude(),
        request.longitude(),
        request.dataHora());
  }

  @GetMapping("/resumo")
  public List<JornadaResumoResponse> resumo(@RequestParam LocalDate data) {
    return jornadaTrackingService.listarResumo(data);
  }

  @GetMapping("/usuarios/{usuarioId}/rota")
  public List<JornadaRotaPontoResponse> rota(@PathVariable Long usuarioId, @RequestParam LocalDate data) {
    return jornadaTrackingService.obterRota(usuarioId, data);
  }
}