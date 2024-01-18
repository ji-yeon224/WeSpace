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
                print("authmanager")
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
                    } else {
                        do {
                            let result = try JSONDecoder().decode(ErrorResponse.self, from: data.data)
                            if let error = RefreshError(rawValue: result.errorCode) {
                                print(error.localizedDescription)
                                switch error {
                                case .E02, .E03, .E06:
                                    value.onNext(RefreshResultType.login(error: result))
                                case .E04:
                                    value.onNext(RefreshResultType.success(token: UserDefaultsManager.accessToken))
                                case .E05:
                                    value.onNext(RefreshResultType.error)
                                }
                            } else {
                                value.onNext(RefreshResultType.error)
                            }
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
