//
//  KakaoLoginManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import RxSwift

final class KakaoLoginManager {
    static let shared = KakaoLoginManager()
    private init() { }
    
    let disposeBag = DisposeBag()
    let loginRequest = PublishSubject<Result<String, Error>>()
    
    func requestLogin()  {
        // 카카오톡 앱 로그인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    self.loginRequest.onNext(.failure(error))
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    guard let oauthToken = oauthToken else {
//                        self.loginRequest.onNext(.failure(error))
                        return
                    }
                    self.loginRequest.onNext(.success(oauthToken.accessToken))
                }
            }
        } else { // 웹으로 로그인
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    self.loginRequest.onNext(.failure(error))
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    guard let oauthToken = oauthToken else {
//                        self.loginRequest.onNext(.failure(error))
                        return
                    }
                    self.loginRequest.onNext(.success(oauthToken.accessToken))
                }
            }
        }
    }
    
    func kakaoUnlinkAccount() {
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
    }
    func kakaoLogout(completion: @escaping (Bool) -> Void) {
        UserApi.shared.logout { (error) in
            if let error = error {
                print(error)
                completion(false)
            } else {
                print("logout() success.")
                completion(true)
            }
        }
    }
    
}
