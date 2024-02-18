//
//  OnBoardingViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit
import RxSwift
import RxCocoa

final class OnBoardingViewController: BaseViewController {
    
    private let mainView = OnBoardingView()
    private let disposeBag = DisposeBag()
    
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
        mainView.startButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                let vc = LoginViewController()
                vc.delegate = self
                let nav = PageSheetManager.customDetent(vc, height: 300)
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}

extension OnBoardingViewController: LoginViewControllerDelegate {
    func presentJoinView() {
        let vc = JoinViewController()
        let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
        nav.setupBarAppearance()
        present(nav, animated: true)
    }
    
    
}
