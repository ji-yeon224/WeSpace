//
//  UserDefaultsManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation

@propertyWrapper
struct Defaults<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
final class UserDefaultsManager {
    private init() { }
    enum Key: String {
        case deviceToken
        case accessToken
        case refresh
    }
    
    @Defaults(key: Key.deviceToken.rawValue, defaultValue: "") static var deviceToken
}

