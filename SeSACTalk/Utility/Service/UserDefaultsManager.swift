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
        case isLogin
        case deviceToken
        case accessToken
        case refreshToken
        case nickName
        case userId
        case accessTokenExpire
        case refreshTokenExpire
    }
    
    @Defaults(key: Key.isLogin.rawValue, defaultValue: false) static var isLogin
    @Defaults(key: Key.deviceToken.rawValue, defaultValue: "") static var deviceToken
    @Defaults(key: Key.accessToken.rawValue, defaultValue: "") static var accessToken
    @Defaults(key: Key.refreshToken.rawValue, defaultValue: "") static var refreshToken
    @Defaults(key: Key.nickName.rawValue, defaultValue: "") static var nickName
    @Defaults(key: Key.userId.rawValue, defaultValue: -1) static var userId
    @Defaults(key: Key.accessTokenExpire.rawValue, defaultValue: Date()) static var accessTokenExpire
    @Defaults(key: Key.refreshTokenExpire.rawValue, defaultValue: Date()) static var refreshTokenExpire
    
    
    static func setToken(token: Token) {
        UserDefaultsManager.isLogin = true
        UserDefaultsManager.accessToken = token.accessToken
        UserDefaultsManager.refreshToken = token.refreshToken
        UserDefaultsManager.accessTokenExpire = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        UserDefaultsManager.refreshTokenExpire = Calendar.current.date(byAdding: .hour, value: 12, to: Date()) ?? Date()
        print(UserDefaultsManager.accessTokenExpire)
    }
    
    static func initToken() {
        UserDefaultsManager.isLogin = false
        UserDefaultsManager.accessToken = ""
        UserDefaultsManager.refreshToken = ""
        UserDefaultsManager.userId = 0
        UserDefaultsManager.nickName = ""
        UserDefaultsManager.accessTokenExpire = Date()
        UserDefaultsManager.refreshTokenExpire = Date()
    }
    
    static func setUserInfo(id: Int, nickName: String) {
        UserDefaultsManager.userId = id
        UserDefaultsManager.nickName = nickName
    }
    
}

