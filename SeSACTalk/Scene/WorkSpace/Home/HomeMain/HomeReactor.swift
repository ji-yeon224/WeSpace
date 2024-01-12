//
//  HomeReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation
import ReactorKit

final class HomeReactor: Reactor {
    var initialState: State = State()
    
    
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        <#code#>
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        <#code#>
    }
    
}

extension HomeReactor {
    
}
