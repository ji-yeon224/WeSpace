//
//  LoginViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class LoginViewController: BaseViewController {
    
    private let mainView = LoginView()
    private let disposeBag = DisposeBag()
    
    weak var delegate: LoginViewControllerDelegate?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func configure() {
        super.configure()
    }
    
    private func bind() {
        mainView.joinLabel.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: false)
                owner.delegate?.presentJoinView()
                
            }
            .disposed(by: disposeBag)
        
    }
    
}
