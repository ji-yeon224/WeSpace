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
        profileData: nil
    )
    
    
    enum Action {
        case requestMyInfo
        case changeProfileImage(data: SelectImage)
    }
    
    enum Mutation {
        case myProfileData(data: MyProfile?)
        case msg(msg: String)
        case loginRequest
        case profileImage(data: String?)
    }
    
    struct State {
        var msg: String?
        var loginRequest: Bool
        var profileImage: String?
        var profileData: MyProfile?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMyInfo:
            return requstMyInfo()
        case .changeProfileImage(let data):
            return requestChangeImage(img: data)
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
        }
        return newState
    }
    
}

extension MyProfileReactor {
    
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
