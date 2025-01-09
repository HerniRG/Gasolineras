//
//  MetadataEntity.swift
//  EstacionesDeServicio
//
//  Created by Hernán Rodríguez on 9/1/25.
//


import Foundation
import SwiftData

@Model
class MetadataEntity {
    var lastUpdated: Date
    
    init(lastUpdated: Date = Date()) {
        self.lastUpdated = lastUpdated
    }
}