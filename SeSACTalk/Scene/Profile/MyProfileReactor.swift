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
        myProfile: [],
        msg: nil,
        loginRequest: false,
        profileImage: nil
    )
    
    
    enum Action {
        case requestMyInfo
    }
    
    enum Mutation {
        case myProfileData(data: MyProfile)
        case msg(msg: String)
        case loginRequest
    }
    
    struct State {
        var myProfile: [MyProfileSectionModel]
        var msg: String?
        var loginRequest: Bool
        var profileImage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMyInfo:
            return requstMyInfo()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .myProfileData(let data):
            newState.myProfile = setUserProfile(data: data)
            newState.profileImage = data.profileImage
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        }
        return newState
    }
    
    private func setUserProfile(data: MyProfile) -> [MyProfileSectionModel] {
        let section1: [MyProfileEditItem] = [
            MyProfileEditItem(type: .coin, coin: data.sesacCoin),
            MyProfileEditItem(type: .nickname, subText: data.nickname),
            MyProfileEditItem(type: .phone, subText: data.phone)
        ]
        var section2: [MyProfileEditItem] = []
        section2.append(MyProfileEditItem(type: .email, email: data.email))
        if let vendor = data.vendor {
            section2.append(MyProfileEditItem(type: .linkSocial, vendor: vendor))
        }
        section2.append(MyProfileEditItem(type: .logout))
        
        return [MyProfileSectionModel(section: .section1, items: section1),
                     MyProfileSectionModel(section: .section2, items: section2)]
    }
}

extension MyProfileReactor {
    private func requstMyInfo() -> Observable<Mutation> {
        return UsersAPIManager.shared.request(api: .my, responseType: MyProfileResDto.self)
            .asObservable()
            .map { result -> Mutation in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .myProfileData(data: response.toDomain())
                    }
                    return .msg(msg: UserToastMessage.loadFail.message)
                case .failure(let error):
                    if let error = CommonError(rawValue: error.errorCode) {
                        return .msg(msg: error.localizedDescription)
                    } else {
                        return .loginRequest
                    }
                    
                }
            }
    }
}
