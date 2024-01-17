//
//  AuthIntercepter.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation
import Alamofire
import RxSwift

final class AuthIntercepter: RequestInterceptor {
    
    static let shared = AuthIntercepter()
    private init() { }
    private let disposeBag = DisposeBag()
    private let retryDelay: TimeInterval = 0.5
    private let retryLimit = 2
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(BaseURL.baseURL) == true
        else {
            completion(.success(urlRequest))
            return
        }
        var urlRequest = urlRequest
        urlRequest.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
        
    }
    
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("retry", error.localizedDescription)
        guard request.retryCount < self.retryLimit else {
            completion(.doNotRetry)
            return
        }
        
        AuthAPIManager.shared.request()
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let token):
                    debugPrint("[SUCCESS REFRESH TOKEN] ", token)
                    UserDefaultsManager.accessToken = token
                    print(UserDefaultsManager.refreshToken)
                    completion(.retryWithDelay(self.retryDelay))
                    
                case .login(let error):
                    debugPrint("[ERROR REFRESH TOKEN - REQUEST LOGIN]")
                    UserDefaultsManager.initToken()
                    completion(.doNotRetryWithError(error))
                case .error:
                    debugPrint("[ERROR REFRESH TOKEN]")
                    UserDefaultsManager.initToken()
                    completion(.doNotRetry)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}
