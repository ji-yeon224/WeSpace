//
//  DeviceTokenManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/1/24.
//

import Foundation
import RxSwift

final class DeviceTokenManager {
    static let shared = DeviceTokenManager()
    private init() { }
    private let disposeBag = DisposeBag()
    var saveTokenSuccess = false
    func requestSaveDeviceToken(token: String?) {
        if let token = token {
            UsersAPIManager.shared.request(api: .deviceToken(data: DeviceTokenReq(deviceToken: token)), responseType: EmptyResponse.self)
                .asObservable()
                .debug()
                .subscribe(onNext: { result in
                    switch result {
                    case .success(_):
                        print("[SUCCESS SAVE FCM TOKEN]")
                        self.saveTokenSuccess = true
                    case .failure(let error):
                        if error.errorCode == "E11" {
                            print("[FAIL SAVE FCM TOKEN] " , "잘못된 요청")
                        } else if let error = CommonError(rawValue: error.errorCode) {
                            print("[FAIL SAVE FCM TOKEN] ", error.localizedDescription)
                            
                        }
                        print("ERROR")
                    }
                })
                .disposed(by: disposeBag)
        }
        
    }
}
