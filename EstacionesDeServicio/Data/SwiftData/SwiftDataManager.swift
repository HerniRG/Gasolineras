//
//  SwiftDataManager.swift
//  EstacionesDeServicio
//
//  Created by Hernán Rodríguez on 9/1/25.
//


import Foundation
import SwiftData

@MainActor
class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    let container: ModelContainer
    
    private init() {
        container = try! ModelContainer(for: GasolineraEntity.self, MetadataEntity.self)
    }
    
    // Guardar gasolineras en la base de datos
    func saveGasolineras(_ gasolineras: [Gasolinera], municipalityID: Int, productID: Int) async throws {
        let context = container.mainContext
        // Eliminar gasolineras existentes para evitar duplicados
        let predicate = #Predicate<GasolineraEntity> { entity in
            entity.municipalityID == municipalityID && entity.productID == productID
        }
        let existingGasolineras = try context.fetch(FetchDescriptor(predicate: predicate))
        for gasolinera in existingGasolineras {
            context.delete(gasolinera)
        }

        // Insertar nuevas gasolineras
        for gasolinera in gasolineras {
            let entity = GasolineraEntity(from: gasolinera, municipalityID: municipalityID, productID: productID)
            context.insert(entity)
        }

        // Actualizar la fecha de última actualización
        let metaPredicate = #Predicate<MetadataEntity> { meta in
            meta.municipalityID == municipalityID && meta.productID == productID
        }
        let metadata = try context.fetch(FetchDescriptor(predicate: metaPredicate)).first ?? MetadataEntity(municipalityID: municipalityID, productID: productID)
        metadata.lastUpdated = Date()
        context.insert(metadata)
        
        try context.save()
    }
    
    // Recuperar gasolineras desde la base de datos
    func fetchGasolineras(municipalityID: Int, productID: Int) throws -> [Gasolinera] {
        let context = container.mainContext
        let predicate = #Predicate<GasolineraEntity> { entity in
            entity.municipalityID == municipalityID && entity.productID == productID
        }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let entities = try context.fetch(fetchDescriptor)
        
        // Convertir GasolineraEntity a Gasolinera
        let gasolineras = entities.map { entity -> Gasolinera in
            return Gasolinera(
                id: entity.id,
                rotulo: entity.rotulo,
                direccion: entity.direccion,
                localidad: entity.localidad,
                provincia: entity.provincia,
                horario: entity.horario,
                precioGasolina95: entity.precioGasolina95,
                precioGasolina98: entity.precioGasolina98,
                precioGasoleoA: entity.precioGasoleoA,
                precioGasoleoPremium: entity.precioGasoleoPremium,
                precioGLP: entity.precioGLP,
                precioGNC: entity.precioGNC,
                precioGNL: entity.precioGNL,
                precioHidrogeno: entity.precioHidrogeno,
                precioBioetanol: entity.precioBioetanol,
                precioBiodiesel: entity.precioBiodiesel,
                precioEsterMetilico: entity.precioEsterMetilico,
                longitud: entity.longitud,
                latitud: entity.latitud,
                distancia: entity.distancia
            )
        }
        
        return gasolineras
    }
    
    // Obtener la fecha de última actualización
    func getLastUpdatedDate(municipalityID: Int, productID: Int) throws -> Date? {
        let context = container.mainContext
        let predicate = #Predicate<MetadataEntity> { meta in
            meta.municipalityID == municipalityID && meta.productID == productID
        }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let metadata = try context.fetch(fetchDescriptor).first
        return metadata?.lastUpdated
    }
}
