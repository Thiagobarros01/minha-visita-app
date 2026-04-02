package br.com.minhavisita.domain;

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

@Entity
@Table(name = "checkins")
public class Checkin {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "visita_id")
  private Visita visita;

  @Column(nullable = false)
  private OffsetDateTime dataCheckin;

  @Column(nullable = false)
  private Double latCheckin;

  @Column(nullable = false)
  private Double lngCheckin;

  private OffsetDateTime dataCheckout;

  private Double latCheckout;

  private Double lngCheckout;

  private Long duracaoSegundos;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public Visita getVisita() {
    return visita;
  }

  public void setVisita(Visita visita) {
    this.visita = visita;
  }

  public OffsetDateTime getDataCheckin() {
    return dataCheckin;
  }

  public void setDataCheckin(OffsetDateTime dataCheckin) {
    this.dataCheckin = dataCheckin;
  }

  public Double getLatCheckin() {
    return latCheckin;
  }

  public void setLatCheckin(Double latCheckin) {
    this.latCheckin = latCheckin;
  }

  public Double getLngCheckin() {
    return lngCheckin;
  }

  public void setLngCheckin(Double lngCheckin) {
    this.lngCheckin = lngCheckin;
  }

  public OffsetDateTime getDataCheckout() {
    return dataCheckout;
  }

  public void setDataCheckout(OffsetDateTime dataCheckout) {
    this.dataCheckout = dataCheckout;
  }

  public Double getLatCheckout() {
    return latCheckout;
  }

  public void setLatCheckout(Double latCheckout) {
    this.latCheckout = latCheckout;
  }

  public Double getLngCheckout() {
    return lngCheckout;
  }

  public void setLngCheckout(Double lngCheckout) {
    this.lngCheckout = lngCheckout;
  }

  public Long getDuracaoSegundos() {
    return duracaoSegundos;
  }

  public void setDuracaoSegundos(Long duracaoSegundos) {
    this.duracaoSegundos = duracaoSegundos;
  }
}
