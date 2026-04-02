package br.com.minhavisita.domain;

import java.time.OffsetDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "visitas")
public class Visita {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "usuario_id")
  private Usuario usuario;

  @Column(nullable = false)
  private String clienteNome;

  @Column(nullable = false)
  private String endereco;

  @Column(nullable = false)
  private Double latitude;

  @Column(nullable = false)
  private Double longitude;

  @Column(nullable = false)
  private OffsetDateTime dataAgendada;

  @Column(nullable = false)
  private Integer raioMetros = 100;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private VisitaStatus status = VisitaStatus.AGENDADA;

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

  public String getClienteNome() {
    return clienteNome;
  }

  public void setClienteNome(String clienteNome) {
    this.clienteNome = clienteNome;
  }

  public String getEndereco() {
    return endereco;
  }

  public void setEndereco(String endereco) {
    this.endereco = endereco;
  }

  public Double getLatitude() {
    return latitude;
  }

  public void setLatitude(Double latitude) {
    this.latitude = latitude;
  }

  public Double getLongitude() {
    return longitude;
  }

  public void setLongitude(Double longitude) {
    this.longitude = longitude;
  }

  public OffsetDateTime getDataAgendada() {
    return dataAgendada;
  }

  public void setDataAgendada(OffsetDateTime dataAgendada) {
    this.dataAgendada = dataAgendada;
  }

  public Integer getRaioMetros() {
    return raioMetros;
  }

  public void setRaioMetros(Integer raioMetros) {
    this.raioMetros = raioMetros;
  }

  public VisitaStatus getStatus() {
    return status;
  }

  public void setStatus(VisitaStatus status) {
    this.status = status;
  }
}
