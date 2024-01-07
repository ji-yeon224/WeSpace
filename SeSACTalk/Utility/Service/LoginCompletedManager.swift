//
//  LoginCompletedManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import Foundation
import RxSwift

final class LoginCompletedManager {
    static let shared = LoginCompletedManager()
    private init() { }
    
    
    func requestMyProfile() -> Observable<Result<MyProfile, CommonError>> {
        
        return Observable.create { result in
            UsersAPIManager.shared.request(api: .my, responseType: MyProfileRequestDto.self)
                .asObservable()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(let response):
                        
                        if let data = response {
                            result.onNext(.success(data.toDomain()))
                        }
                        
                    case .failure(let error):
                        let error = CommonError(rawValue: error.errorCode)
                        result.onNext(.failure(error ?? CommonError.E99))
                    }
                }
            
        }
        
    }
}
