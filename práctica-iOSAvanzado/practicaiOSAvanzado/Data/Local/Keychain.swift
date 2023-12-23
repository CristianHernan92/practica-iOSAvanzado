import Foundation
import KeychainSwift

protocol KeychainProtocol{
    func saveToken(token: String)
    func getToken()->String?
    func removeToken()
}

final class Keychain{
    private let tokenKey="TOKEN_KEY"
    private let keychain = KeychainSwift()
}

extension Keychain:KeychainProtocol{
    func saveToken(token: String){
        keychain.set(token, forKey: tokenKey)
    }
    func getToken()->String?{
        keychain.get(tokenKey)
    }
    
    func removeToken(){
        keychain.delete(tokenKey)
    }
}
