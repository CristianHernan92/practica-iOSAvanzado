import Foundation

typealias Heros = [Hero]

struct Hero: Equatable,Decodable {
    let id: String
    let name: String
    let description: String
    let favorite: Bool
    let photo: URL
    
    init(id: String, name: String, description: String, photo: URL, favorite: Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.photo = photo
        self.favorite = favorite
    }
}

