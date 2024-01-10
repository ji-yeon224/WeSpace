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
    private let disposeBag = DisposeBag()
    
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
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
        
    }
    
    func workSpaceTransition() -> Observable<Result<WorkSpace?, CommonError>> {
        
        return Observable.create { result in
            
            WorkspacesAPIManager.shared.request(api: .fetchAll, resonseType: WorkspaceResponseDTO.self)
                .asObservable()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(let response):
                        var value: WorkspaceResponseDTO = []
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
                        if let error = CommonError(rawValue: error.errorCode) {
                            result.onNext(.failure(error))
                        } else {
                            result.onNext(.failure(CommonError.E99))
                        }
                        
                    }
                }
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
