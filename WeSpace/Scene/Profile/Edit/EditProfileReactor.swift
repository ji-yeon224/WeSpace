//
//  EditProfileReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation
import ReactorKit

final class EditProfileReactor: Reactor {
    var initialState: State = State(
        msg: nil,
        loginRequet: false,
        successUpdate: false
    )
    
    enum Action {
        case requestEdit(type: EditProfileType, data: ProfileUpdateReqDTO)
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginReqeust
        case successUpdate
    }
    
    struct State {
        var msg: String?
        var loginRequet: Bool
        var successUpdate: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestEdit(let type, let data):
            return checkAndReqeustUpdate(type: type, data: data)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .msg(let msg):
            newState.msg = msg
        case .loginReqeust:
            newState.loginRequet = true
        case .successUpdate:
            newState.successUpdate = true
        }
        
        return newState
    }
}

extension EditProfileReactor {
    private func checkAndReqeustUpdate(type: EditProfileType, data: ProfileUpdateReqDTO) -> Observable<Mutation> {
        switch type {
        case .editNickname:
            if 1...30 ~= data.nickname.count {
                return self.requestUpdateProfile(data: data)
            } else {
                return .just(.msg(msg: "닉네임은 1글자 이상 30글자 이내로 부탁드려요."))
            }
        case .editPhone:
            if let phone = data.phone, phone.isValidPhone() {
                return self.requestUpdateProfile(data: data)
            } else {
                return .just(.msg(msg: "잘못된 전화번호 형식입니다."))
            }
        }
    }
    
    private func requestUpdateProfile(data: ProfileUpdateReqDTO) -> Observable<Mutation> {
        return UsersAPIManager.shared.request(api: .updateProfile(data: data), responseType: MyProfileResDto.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    return .successUpdate
                case .failure(let error):
                    debugPrint("UPDATE ERROR ", error.errorCode)
                    if let error = UserError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else {
                        return .loginReqeust
                    }
                }
            }
    }
}
