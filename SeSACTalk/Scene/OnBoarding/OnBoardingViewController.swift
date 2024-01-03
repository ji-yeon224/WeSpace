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
                let detentIdentifier = UISheetPresentationController.Detent.Identifier("customDetent")
                let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
                    // safe area bottom을 구하기 위한 선언.
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let safeAreaBottom = windowScene?.windows.first?.safeAreaInsets.bottom ?? 0

                    return 300 - safeAreaBottom
                }
                let nav = UINavigationController(rootViewController: vc)
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [customDetent]
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersGrabberVisible = true
                }
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
