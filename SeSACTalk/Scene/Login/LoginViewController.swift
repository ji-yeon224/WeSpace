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
    
    private let viewModel = LoginViewModel()
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
        
        let input = LoginViewModel.Input(kakaoLogin: mainView.kakaoButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.loginSuccess
            .bind(with: self) { owner, _ in
                let vc = InitialViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.setupBarAppearance()
                owner.view.window?.rootViewController = nav
                owner.view.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)
        
        mainView.emailButton.rx.tap
            .bind { _ in
                KakaoLoginManager.shared.kakaoUnlinkAccount()
            }
            .disposed(by: disposeBag)
        
        mainView.joinLabel.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: false)
                owner.delegate?.presentJoinView()
                
            }
            .disposed(by: disposeBag)
        
    }
    
}
