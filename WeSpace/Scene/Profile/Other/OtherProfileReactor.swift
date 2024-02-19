//
//  OtherProfileReactor.swift
//  WeSpace
//
//  Created by 김지연 on 2/19/24.
//

import Foundation
import ReactorKit

final class OtherProfileReactor: Reactor {
    var initialState: State = State( 
        userInfo: [],
        msg: nil,
        loginRequest: false,
        profileImage: nil
    )
    
    enum Action {
        case requestProfile(id: Int)
    }
    
    enum Mutation {
        case userInfo(data: User)
        case msg(msg: String)
        case loginRequest
    }
    
    struct State {
        var userInfo: [OtherProfileItem]
        var msg: String?
        var loginRequest: Bool
        var profileImage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestProfile(let id):
            return requestUserInfo(id: id)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .userInfo(let data):
            let item = [
                OtherProfileItem(title: "닉네임", subText: data.nickname),
                OtherProfileItem(title: "이메일", subText: data.email)
            ]
            newState.profileImage = data.profileImage
            newState.userInfo = item
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        }
        
        return newState
    }
    
    private func requestUserInfo(id: Int) -> Observable<Mutation> {
        return UsersAPIManager.shared.request(api: .otherUser(userId: id), responseType: UserResDTO.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .userInfo(data: response.toDomain())
                    }
                    return .msg(msg: UserToastMessage.loadFail.message)
                case .failure(let error):
                    if let error = UserError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else {
                        return .loginRequest
                    }
                        
                }
                
            }
    }
}
