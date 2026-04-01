package br.com.minhavisita.service;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

import org.springframework.stereotype.Service;

import br.com.minhavisita.domain.Usuario;
import br.com.minhavisita.domain.Visita;
import br.com.minhavisita.domain.VisitaStatus;
import br.com.minhavisita.repository.VisitaRepository;

@Service
public class VisitaService {
  private final VisitaRepository visitaRepository;
  private final UsuarioService usuarioService;

  public VisitaService(VisitaRepository visitaRepository, UsuarioService usuarioService) {
    this.visitaRepository = visitaRepository;
    this.usuarioService = usuarioService;
  }

  public Visita criar(Visita visita, Long usuarioId) {
    Usuario usuario = usuarioService.buscar(usuarioId);
    visita.setUsuario(usuario);
    if (visita.getRaioMetros() == null || visita.getRaioMetros() <= 0) {
      visita.setRaioMetros(100);
    }
    if (visita.getStatus() == null) {
      visita.setStatus(VisitaStatus.AGENDADA);
    }
    return visitaRepository.save(visita);
  }

  public Visita buscar(Long id) {
    return visitaRepository.findById(id)
        .orElseThrow(() -> new NotFoundException("Visita nao encontrada"));
  }

  public List<Visita> listarPorUsuarioEDia(Long usuarioId, LocalDate dia) {
    OffsetDateTime inicio = dia.atStartOfDay().atOffset(ZoneOffset.UTC);
    OffsetDateTime fim = dia.plusDays(1).atStartOfDay().atOffset(ZoneOffset.UTC).minusNanos(1);
    return visitaRepository.findByUsuarioIdAndDataAgendadaBetween(usuarioId, inicio, fim);
  }

  public Visita salvar(Visita visita) {
    return visitaRepository.save(visita);
  }
}
