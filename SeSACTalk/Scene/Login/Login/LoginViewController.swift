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
import ReactorKit

final class LoginViewController: BaseViewController, View {
    
    private let mainView = LoginView()
    var disposeBag = DisposeBag()
    
    weak var delegate: LoginViewControllerDelegate?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = LoginReactor()
        
    }
    
    override func configure() {
        super.configure()
    }
    
    func bind(reactor: LoginReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: LoginReactor) {
        
        mainView.kakaoButton.rx.tap
            .map { Reactor.Action.kakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.emailButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                let vc = EmailLoginViewController()
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.joinLabel.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: false)
                owner.delegate?.presentJoinView()
                
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: LoginReactor) {
        
        reactor.state
            .map { $0.kakaoLoginSuccess }
            .distinctUntilChanged()
            .map { Reactor.Action.requestKakaoComplete(oauth: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loginSuccess }
            .distinctUntilChanged()
            .bind(with: self) { owner, _ in
                owner.presentInitialView()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.msg }
            .distinctUntilChanged()
            .bind(with: self, onNext: { owner, value in
                if let value = value {
                    owner.showToastMessage(message: value, position: .top)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.indicator }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.showIndicator(show: value, position: .top)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func presentInitialView() {
        let vc = InitialViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.setupBarAppearance()
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
    }
    
    private func presentEmailLoginView() {
        let vc = EmailLoginViewController()
        let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
        nav.setupBarAppearance()
        present(nav, animated: true)
    }
    
    
}
