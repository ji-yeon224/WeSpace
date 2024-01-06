//
//  EmailLoginViewModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EmailLoginViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) {
        
    }
}
