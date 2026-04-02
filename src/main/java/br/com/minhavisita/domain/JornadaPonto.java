package br.com.minhavisita.domain;

import java.time.OffsetDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(
    name = "jornadas_ponto",
    indexes = @Index(name = "idx_jornada_ponto_jornada_data", columnList = "jornada_dia_id,dataHora")
)
public class JornadaPonto {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "jornada_dia_id")
  private JornadaDia jornadaDia;

  @Column(nullable = false)
  private Double latitude;

  @Column(nullable = false)
  private Double longitude;

  @Column(nullable = false)
  private OffsetDateTime dataHora;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public JornadaDia getJornadaDia() {
    return jornadaDia;
  }

  public void setJornadaDia(JornadaDia jornadaDia) {
    this.jornadaDia = jornadaDia;
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

  public OffsetDateTime getDataHora() {
    return dataHora;
  }

  public void setDataHora(OffsetDateTime dataHora) {
    this.dataHora = dataHora;
  }
}
