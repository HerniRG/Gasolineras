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
    @Attribute(.unique) var key: String
    var municipalityID: Int
    var productID: Int
    var lastUpdated: Date

    init(municipalityID: Int, productID: Int, lastUpdated: Date = Date()) {
        self.key = "\(municipalityID)-\(productID)"
        self.municipalityID = municipalityID
        self.productID = productID
        self.lastUpdated = lastUpdated
    }
}