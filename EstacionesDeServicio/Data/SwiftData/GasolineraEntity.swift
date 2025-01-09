//
//  GasolineraEntity.swift
//  EstacionesDeServicio
//
//  Created by Hernán Rodríguez on 9/1/25.
//


import Foundation
import MapKit
import SwiftData

@Model
class GasolineraEntity {
    @Attribute(.unique) var id: String
    var rotulo: String
    var direccion: String
    var localidad: String
    var provincia: String
    var horario: String
    var precioGasolina95: Double?
    var precioGasolina98: Double?
    var precioGasoleoA: Double?
    var precioGasoleoPremium: Double?
    var precioGLP: Double?
    var precioGNC: Double?
    var precioGNL: Double?
    var precioHidrogeno: Double?
    var precioBioetanol: Double?
    var precioBiodiesel: Double?
    var precioEsterMetilico: Double?
    var longitud: Double?
    var latitud: Double?
    var distancia: Double?
    
    // Computed property para obtener la coordenada
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud ?? 0.0, longitude: longitud ?? 0.0)
    }
    
    // Inicializador para crear una entidad desde una instancia de Gasolinera
    init(from gasolinera: Gasolinera) {
        self.id = gasolinera.id
        self.rotulo = gasolinera.rotulo
        self.direccion = gasolinera.direccion
        self.localidad = gasolinera.localidad
        self.provincia = gasolinera.provincia
        self.horario = gasolinera.horario
        self.precioGasolina95 = gasolinera.precioGasolina95
        self.precioGasolina98 = gasolinera.precioGasolina98
        self.precioGasoleoA = gasolinera.precioGasoleoA
        self.precioGasoleoPremium = gasolinera.precioGasoleoPremium
        self.precioGLP = gasolinera.precioGLP
        self.precioGNC = gasolinera.precioGNC
        self.precioGNL = gasolinera.precioGNL
        self.precioHidrogeno = gasolinera.precioHidrogeno
        self.precioBioetanol = gasolinera.precioBioetanol
        self.precioBiodiesel = gasolinera.precioBiodiesel
        self.precioEsterMetilico = gasolinera.precioEsterMetilico
        self.longitud = gasolinera.longitud
        self.latitud = gasolinera.latitud
        self.distancia = gasolinera.distancia
    }
}