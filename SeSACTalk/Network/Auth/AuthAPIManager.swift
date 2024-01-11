//
//  AuthManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation
import Moya
import RxSwift

final class AuthAPIManager {
    
    static let shared = AuthAPIManager()
    private init() { }
    private let provider = MoyaProvider<AuthAPI>()
    
    func request() -> Observable<RefreshResultType> {
        
        return Observable.create { value in
            self.provider.request(.auth) { result in
                
                switch result {
                case .success(let data):
                    let statusCode = data.statusCode
                    if statusCode == 200 {
                        do {
                            let result = try JSONDecoder().decode(AuthResponseDTO.self, from: data.data)
                            UserDefaultsManager.accessToken = result.accessToken
                            
                            value.onNext(RefreshResultType.success(token: result.accessToken))
                        } catch {
                            value.onNext(RefreshResultType.error)
                        }
                    }
                case .failure(let error):
                    value.onNext(RefreshResultType.error)
                }
            }
            return Disposables.create()
            
            
            
        }
        
    }
    
    
}
