package br.com.minhavisita.service;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.minhavisita.domain.JornadaDia;
import br.com.minhavisita.domain.JornadaPonto;
import br.com.minhavisita.domain.Usuario;
import br.com.minhavisita.domain.Visita;
import br.com.minhavisita.domain.VisitaStatus;
import br.com.minhavisita.repository.JornadaDiaRepository;
import br.com.minhavisita.repository.JornadaPontoRepository;
import br.com.minhavisita.web.dto.JornadaResumoResponse;
import br.com.minhavisita.web.dto.JornadaRotaPontoResponse;

@Service
public class JornadaTrackingService {
  private final UsuarioService usuarioService;
  private final VisitaService visitaService;
  private final JornadaDiaRepository jornadaDiaRepository;
  private final JornadaPontoRepository jornadaPontoRepository;

  public JornadaTrackingService(
      UsuarioService usuarioService,
      VisitaService visitaService,
      JornadaDiaRepository jornadaDiaRepository,
      JornadaPontoRepository jornadaPontoRepository
  ) {
    this.usuarioService = usuarioService;
    this.visitaService = visitaService;
    this.jornadaDiaRepository = jornadaDiaRepository;
    this.jornadaPontoRepository = jornadaPontoRepository;
  }

  @Transactional
  public void registrarPing(Long usuarioId, Double latitude, Double longitude, OffsetDateTime dataHora) {
    if (usuarioId == null || latitude == null || longitude == null) {
      throw new BadRequestException("usuarioId, latitude e longitude sao obrigatorios");
    }

    Usuario usuario = usuarioService.buscar(usuarioId);
    OffsetDateTime timestamp = dataHora != null ? dataHora : OffsetDateTime.now();
    LocalDate dia = timestamp.toLocalDate();

    JornadaDia jornadaDia = jornadaDiaRepository.findByUsuarioIdAndDia(usuario.getId(), dia)
        .orElseGet(() -> {
          JornadaDia novaJornada = new JornadaDia();
          novaJornada.setUsuario(usuario);
          novaJornada.setDia(dia);
          novaJornada.setKmPercorridos(0.0);
          return novaJornada;
        });

    if (jornadaDia.getLastLatitude() != null && jornadaDia.getLastLongitude() != null) {
      double segmento = GeoUtils.distanciaMetros(
          jornadaDia.getLastLatitude(),
          jornadaDia.getLastLongitude(),
          latitude,
          longitude);
      jornadaDia.setKmPercorridos(jornadaDia.getKmPercorridos() + (segmento / 1000.0));
    }

    jornadaDia.setLastLatitude(latitude);
    jornadaDia.setLastLongitude(longitude);
    jornadaDia.setAtualizacaoEm(timestamp);
    jornadaDia = jornadaDiaRepository.save(jornadaDia);

    JornadaPonto ponto = new JornadaPonto();
    ponto.setJornadaDia(jornadaDia);
    ponto.setLatitude(latitude);
    ponto.setLongitude(longitude);
    ponto.setDataHora(timestamp);
    jornadaPontoRepository.save(ponto);

    if (jornadaPontoRepository.countByJornadaDiaId(jornadaDia.getId()) > 500) {
      jornadaPontoRepository.findTop1ByJornadaDiaIdOrderByDataHoraAsc(jornadaDia.getId())
          .ifPresent(jornadaPontoRepository::delete);
    }
  }

  @Transactional(readOnly = true)
  public List<JornadaResumoResponse> listarResumo(LocalDate dia) {
    List<Usuario> operadores = usuarioService.listarOperadores();
    Map<Long, JornadaDia> jornadaPorUsuario = jornadaDiaRepository.findByDia(dia).stream()
        .collect(Collectors.toMap(jornada -> jornada.getUsuario().getId(), Function.identity()));

    List<JornadaResumoResponse> resumo = new ArrayList<>();

    for (Usuario operador : operadores) {
      List<Visita> visitas = visitaService.listarPorUsuarioEDia(operador.getId(), dia);
      List<String> locaisVisitados = visitas.stream()
          .filter(visita -> visita.getStatus() == VisitaStatus.CONCLUIDA)
          .map(Visita::getEndereco)
          .distinct()
          .toList();

          JornadaDia jornada = jornadaPorUsuario.get(operador.getId());
          Double latitudeAtual = jornada != null ? jornada.getLastLatitude() : null;
          Double longitudeAtual = jornada != null ? jornada.getLastLongitude() : null;
          OffsetDateTime atualizacaoEm = jornada != null ? jornada.getAtualizacaoEm() : null;
          double kmPercorridos = jornada != null ? jornada.getKmPercorridos() : 0.0;

      resumo.add(new JornadaResumoResponse(
          operador.getId(),
          operador.getNome(),
          operador.getEmail(),
          latitudeAtual,
          longitudeAtual,
          kmPercorridos,
          atualizacaoEm,
          locaisVisitados,
          locaisVisitados.size()));
    }

    return resumo;
  }

  @Transactional(readOnly = true)
  public List<JornadaRotaPontoResponse> obterRota(Long usuarioId, LocalDate dia) {
    return jornadaDiaRepository.findByUsuarioIdAndDia(usuarioId, dia)
        .map(jornada -> jornadaPontoRepository.findByJornadaDiaIdOrderByDataHoraAsc(jornada.getId())
            .stream()
            .map(ponto -> new JornadaRotaPontoResponse(
                ponto.getLatitude(),
                ponto.getLongitude(),
                ponto.getDataHora()))
            .toList())
        .orElse(List.of());
  }
}