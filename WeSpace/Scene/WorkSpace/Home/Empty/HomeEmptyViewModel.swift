//
//  HomeEmptyViewModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeEmptyViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let requestUserInfo: BehaviorRelay<Bool>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) {
        
        input.requestUserInfo
            .flatMap { _ in
                LoginCompletedManager.shared.requestMyProfile()
            }
            .subscribe(with: self) { owner, profile in
                switch profile {
                case .success(let result):
                    print(result.nickname)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}
