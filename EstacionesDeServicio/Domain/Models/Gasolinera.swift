import Foundation
import MapKit

struct Gasolinera: Identifiable, Codable {
    let id: String
    let rotulo: String
    let direccion: String
    let localidad: String
    let provincia: String
    let horario: String
    let precioGasolina95: Double?
    let precioGasolina98: Double?
    let precioGasoleoA: Double?
    let precioGasoleoPremium: Double?
    let precioGLP: Double?
    let longitud: Double?
    let latitud: Double?
    var distancia: Double?

    enum CodingKeys: String, CodingKey {
        case id = "IDEESS"
        case rotulo = "Rótulo"
        case direccion = "Dirección"
        case localidad = "Localidad"
        case provincia = "Provincia"
        case horario = "Horario"
        case precioGasolina95 = "Precio Gasolina 95 E5"
        case precioGasolina98 = "Precio Gasolina 98 E5"
        case precioGasoleoA = "Precio Gasoleo A"
        case precioGasoleoPremium = "Precio Gasoleo Premium"
        case precioGLP = "Precio GLP"
        case longitud = "Longitud (WGS84)"
        case latitud = "Latitud"
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud ?? 0.0, longitude: longitud ?? 0.0)
    }

    // Inicializador manual
    init(
        id: String = UUID().uuidString,
        rotulo: String,
        direccion: String,
        localidad: String,
        provincia: String,
        horario: String,
        precioGasolina95: Double?,
        precioGasolina98: Double?,
        precioGasoleoA: Double?,
        precioGasoleoPremium: Double?,
        precioGLP: Double?,
        longitud: Double?,
        latitud: Double?,
        distancia: Double? = nil
    ) {
        self.id = id
        self.rotulo = rotulo
        self.direccion = direccion
        self.localidad = localidad
        self.provincia = provincia
        self.horario = horario
        self.precioGasolina95 = precioGasolina95
        self.precioGasolina98 = precioGasolina98
        self.precioGasoleoA = precioGasoleoA
        self.precioGasoleoPremium = precioGasoleoPremium
        self.precioGLP = precioGLP
        self.longitud = longitud
        self.latitud = latitud
        self.distancia = distancia
    }

    // Sobrescribe el inicializador de Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        rotulo = try container.decode(String.self, forKey: .rotulo)
        direccion = try container.decode(String.self, forKey: .direccion)
        localidad = try container.decode(String.self, forKey: .localidad)
        provincia = try container.decode(String.self, forKey: .provincia)
        horario = try container.decode(String.self, forKey: .horario)

        // Parse prices
        precioGasolina95 = Gasolinera.decodePrice(for: .precioGasolina95, from: container)
        precioGasolina98 = Gasolinera.decodePrice(for: .precioGasolina98, from: container)
        precioGasoleoA = Gasolinera.decodePrice(for: .precioGasoleoA, from: container)
        precioGasoleoPremium = Gasolinera.decodePrice(for: .precioGasoleoPremium, from: container)
        precioGLP = Gasolinera.decodePrice(for: .precioGLP, from: container)

        // Parse coordinates
        longitud = Gasolinera.decodeCoordinate(for: .longitud, from: container)
        latitud = Gasolinera.decodeCoordinate(for: .latitud, from: container)
    }

    /// Método auxiliar para decodificar precios
    private static func decodePrice(for key: CodingKeys, from container: KeyedDecodingContainer<CodingKeys>) -> Double? {
        guard let stringValue = try? container.decodeIfPresent(String.self, forKey: key), !stringValue.isEmpty else {
            return nil
        }
        let normalizedValue = stringValue.replacingOccurrences(of: ",", with: ".")
        return Double(normalizedValue)
    }

    /// Método auxiliar para decodificar coordenadas
    private static func decodeCoordinate(for key: CodingKeys, from container: KeyedDecodingContainer<CodingKeys>) -> Double? {
        guard let stringValue = try? container.decodeIfPresent(String.self, forKey: key), !stringValue.isEmpty else {
            return nil
        }
        let normalizedValue = stringValue.replacingOccurrences(of: ",", with: ".")
        return Double(normalizedValue)
    }
}
