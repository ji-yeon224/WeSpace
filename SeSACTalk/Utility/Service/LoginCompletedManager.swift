//
//  LoginCompletedManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit
import RxSwift

final class LoginCompletedManager {
    static let shared = LoginCompletedManager()
    private init() { }
    private let disposeBag = DisposeBag()
    
    
    
    func requestMyProfile() -> Observable<Result<MyProfile, ErrorResponse>> {
        
        return Observable.create { result in
            UsersAPIManager.shared.request(api: .my, responseType: MyProfileResDto.self)
                .asObservable()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(let response):
                        
                        if let data = response {
                            result.onNext(.success(data.toDomain()))
                        }
                        
                    case .failure(let error):
                        result.onNext(.failure(error))
                    }
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
        
    }
    
    func workSpaceTransition() -> Observable<Result<WorkSpace?, ErrorResponse>> {
        
        return Observable.create { result in
            
            WorkspacesAPIManager.shared.request(api: .fetchAll, resonseType: AllWorkspaceReDTO.self)
                .asObservable()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(let response):
                        var value: AllWorkspaceReDTO = []
                        if let data = response {
                            value = data
                            if !value.isEmpty {
                                result.onNext(.success(value[0].toDomain()))
                            } else {
                                result.onNext(.success(nil))
                            }
                           
                        } else {
                            result.onNext(.success(nil))
                        }
                    case .failure(let error):
                        result.onNext(.failure(error))
                        
                    }
                }
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
