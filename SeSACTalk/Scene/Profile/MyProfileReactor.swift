//
//  MyProfileReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation
import ReactorKit

final class MyProfileReactor: Reactor {
    
    var initialState: State = State(
        msg: nil,
        loginRequest: false,
        profileImage: nil,
        profileData: nil,
        logoutSuccess: false
    )
    
    
    enum Action {
        case requestMyInfo
        case changeProfileImage(data: SelectImage)
        case requestLogout(vendor: String?)
    }
    
    enum Mutation {
        case myProfileData(data: MyProfile?)
        case msg(msg: String)
        case loginRequest
        case profileImage(data: String?)
        case logoutSuccess
    }
    
    struct State {
        var msg: String?
        var loginRequest: Bool
        var profileImage: String?
        var profileData: MyProfile?
        var logoutSuccess: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMyInfo:
            return requstMyInfo()
        case .changeProfileImage(let data):
            return requestChangeImage(img: data)
        case .requestLogout(let vendor):
            return .concat(
                requestFCMDelete(),
                requestLogout(vendor: vendor)
            )
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .myProfileData(let data):
            newState.profileData = data
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        case .profileImage(let data):
            newState.profileImage = data
        case .logoutSuccess:
            newState.logoutSuccess = true
        }
        return newState
    }
    
}

extension MyProfileReactor {
    
    private func requestLogout(vendor: String?) -> Observable<Mutation> {
        
        if vendor == "kakao" {
            return requestKakaoLogout()
        } else if vendor == "apple" {
            return .just(.logoutSuccess)
        } else {
            return .just(.logoutSuccess)
        }
    }
    
    private func requestKakaoLogout() -> Observable<Mutation> {
        return Observable.create { observer in
            KakaoLoginManager.shared.kakaoLogout { value in
                if value {
                    observer.onNext(.logoutSuccess)
                } else {
                    observer.onNext(.msg(msg: "로그아웃에 실패하였습니다."))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func requestFCMDelete() -> Observable<Mutation> {
        
        return UsersAPIManager.shared.request(api: .logout, responseType: EmptyResponse.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(_):
                    debugPrint("LOGOUT SUCCESS")
                    DeviceTokenManager.shared.saveTokenSuccess = false
                    UserDefaultsManager.deviceToken = ""
                    return .empty()
                case .failure(let error):
                    debugPrint("LOGOUT ERROR ", error.errorCode)
                    return .empty()
                }
            }
    }

    
    private func requestChangeImage(img: SelectImage) -> Observable<Mutation> {
        if let img = img.img, let imgData = img.imageToData() {
            return UsersAPIManager.shared.request(api: .profile(data: ProfileImageReqDTO(image: imgData)), responseType: MyProfileResDto.self)
                .asObservable()
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let response):
                        if let response = response {
                            NotificationCenter.default.post(name: .refreshProfile, object: nil, userInfo: [UserInfo.imageUrl: response.profileImage ?? ""])
                            return .concat(
                                .just(.profileImage(data: response.profileImage)),
                                .just(.msg(msg: "")),
                                .just(.msg(msg: UserToastMessage.changeProfileImage.message))
                            )
                        }
                        return .just(.msg(msg: UserToastMessage.loadFail.message))
                    case .failure(let error):
                        if let error = UserError(rawValue: error.errorCode) {
                            return .just(.msg(msg: error.localizedDescription))
                        } else if let error = CommonError(rawValue: error.errorCode) {
                            return .just(.msg(msg: error.localizedDescription))
                        } else {
                            return .just(.loginRequest)
                        }
                    }
                    
                }
        } else {
            return .just(.msg(msg: UserToastMessage.otherError.message))
        }
        
    }
    
    private func requstMyInfo() -> Observable<Mutation> {
        return UsersAPIManager.shared.request(api: .my, responseType: MyProfileResDto.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .concat(
                            .just(.myProfileData(data: response.toDomain())),
                            .just(.myProfileData(data: nil))
                        )
                    }
                    return .just(.msg(msg: UserToastMessage.loadFail.message))
                case .failure(let error):
                    if let error = CommonError(rawValue: error.errorCode) {
                        return .just(.msg(msg: error.localizedDescription))
                    } else {
                        return .just(.loginRequest)
                    }
                    
                }
            }
    }
}
