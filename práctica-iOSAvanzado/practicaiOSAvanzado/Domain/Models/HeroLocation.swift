import Foundation

typealias HeroLocations = [HeroLocation]

struct HeroLocation: Decodable {
    let dateShow: String
    let id: String
    let hero: HeroId
    let latitud, longitud: String

    
    init(dateShow: String, id: String, hero: HeroId, latitud: String, longitud: String) {
        self.dateShow = dateShow
        self.id = id
        self.hero = hero
        self.latitud = latitud
        self.longitud = longitud
    }
}

struct HeroId: Codable {
    let id: String
}
