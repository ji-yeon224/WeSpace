//
//  CoinReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/15/24.
//

import Foundation
import ReactorKit

final class CoinReactor: Reactor {
    var initialState: State = State(
        msg: nil,
        loginRequest: false,
        itemList: []
    )
    
    
    enum Action {
        case requestItemList
        
    }
    
    enum Mutation {
        case itemList(data: [CoinItem])
        case msg(msg: String)
        case loginRequest
    }
    
    struct State {
        var msg: String?
        var loginRequest: Bool
        var itemList: [CoinItem]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestItemList:
            return requestItemList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .itemList(let data):
            newState.itemList = data
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest:
            newState.loginRequest = true
        }
        
        return newState
    }
    
    
}

extension CoinReactor {
    private func requestItemList() -> Observable<Mutation> {
        return CoinsAPIManager.shared.request(api: .coinItemList, responseType: CoinItemListRes.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        return .just(.itemList(data: response.map { $0.toDomain() }))
                    } else {
                        return .just(.msg(msg: "상품을 로드하는데 문제가 발생하였습니다."))
                    }
                case .failure(let error):
                    debugPrint("CoinList ERROR ", error.errorCode)
                    if let error = CommonError(rawValue: error.errorCode) {
                        return .just(.msg(msg: error.localizedDescription))
                    } else {
                        return .just(.loginRequest)
                    }
                }
                
            }
    }
}
