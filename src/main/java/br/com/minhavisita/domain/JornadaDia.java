package br.com.minhavisita.domain;

import java.time.LocalDate;
import java.time.OffsetDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
    name = "jornadas_dia",
    uniqueConstraints = @UniqueConstraint(name = "uk_jornada_usuario_dia", columnNames = {"usuario_id", "dia"})
)
public class JornadaDia {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "usuario_id")
  private Usuario usuario;

  @Column(nullable = false)
  private LocalDate dia;

  @Column
  private Double lastLatitude;

  @Column
  private Double lastLongitude;

  @Column(nullable = false)
  private Double kmPercorridos = 0.0;

  @Column
  private OffsetDateTime atualizacaoEm;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public Usuario getUsuario() {
    return usuario;
  }

  public void setUsuario(Usuario usuario) {
    this.usuario = usuario;
  }

  public LocalDate getDia() {
    return dia;
  }

  public void setDia(LocalDate dia) {
    this.dia = dia;
  }

  public Double getLastLatitude() {
    return lastLatitude;
  }

  public void setLastLatitude(Double lastLatitude) {
    this.lastLatitude = lastLatitude;
  }

  public Double getLastLongitude() {
    return lastLongitude;
  }

  public void setLastLongitude(Double lastLongitude) {
    this.lastLongitude = lastLongitude;
  }

  public Double getKmPercorridos() {
    return kmPercorridos;
  }

  public void setKmPercorridos(Double kmPercorridos) {
    this.kmPercorridos = kmPercorridos;
  }

  public OffsetDateTime getAtualizacaoEm() {
    return atualizacaoEm;
  }

  public void setAtualizacaoEm(OffsetDateTime atualizacaoEm) {
    this.atualizacaoEm = atualizacaoEm;
  }
}
