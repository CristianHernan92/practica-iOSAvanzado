import Foundation

typealias Heroes = [Hero]

final class Hero: Decodable {
    let id: String
    let name: String
    let description: String
    let photo: URL
    let favorite: Bool
    
    init(id: String, name: String, description: String, photo: URL, favorite: Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.photo = photo
        self.favorite = favorite
    }
}
