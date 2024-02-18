//
//  WorkspacesAPIManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import Foundation
import Moya
import RxSwift

final class WorkspacesAPIManager {
    static let shared = WorkspacesAPIManager()
    private init() { }
    
    private let provider = MoyaProvider<WorkspacesAPI>(session: Session(interceptor: AuthIntercepter.shared))
    
    func request<T: Decodable>(api: WorkspacesAPI, resonseType: T.Type) -> Single<Result<T?, ErrorResponse>> {
        return Single.create { single in
            self.provider.request(api) { result in
                switch result {
                case .success(let response):
                    let code = response.statusCode
                    if code == 200 {
                        do {
                            if response.data.isEmpty {
                                single(.success(.success(nil)))
                            } else {
                                let data = try JSONDecoder().decode(T.self, from: response.data)
                                single(.success(.success(data)))
                            }
                            
                        } catch {
                            print("decode error", error)
                            single(.success(.failure(ErrorResponse(errorCode: "E99"))))
                        }
                    } else {
                        do {
                            let e = try JSONDecoder().decode(ErrorResponse.self, from: response.data)
                            print("workspacemanager ", e.errorCode)
                            single(.success(.failure(e)))
                        } catch {
                            print("error decoded Error")
                            let e = ErrorResponse(errorCode: "E99")
                            single(.success(.failure(e)))
                        }
                    }
                    
                    
                case .failure(let error):
                    guard let errorValue = error.response else {
                        single(.success(.failure( ErrorResponse(errorCode: "E99"))))
                        return
                    }
                    
                    do {
                        let e = try JSONDecoder().decode(ErrorResponse.self, from: errorValue.data)
                        single(.success(.failure(e)))
                    } catch {
                        let e = ErrorResponse(errorCode: "E99")
                        single(.success(.failure(e)))
                    }
                    
                }
            }
            
            return Disposables.create()
        }
    }
    
}
