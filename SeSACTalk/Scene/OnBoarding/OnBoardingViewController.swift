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
                let nav = UINavigationController(rootViewController: vc)
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersGrabberVisible = true
                }
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
