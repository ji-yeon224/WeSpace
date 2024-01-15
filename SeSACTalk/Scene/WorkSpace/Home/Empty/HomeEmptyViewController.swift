//
//  HomeEmptyViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class HomeEmptyViewController: BaseViewController {
    
    private let mainView = HomeEmptyView()
    private let viewModel = HomeEmptyViewModel()
    private let disposeBag = DisposeBag()
    
    private let requestUserInfo = BehaviorRelay(value: true)
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    override func configure() {
        view.backgroundColor = Constants.Color.secondaryBG
        SideMenuVCManager.shared.initSideMenu(vc: self, workspace: [])
    }
    
    func bind() {
        
        mainView.makeButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = MakeViewController()
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        mainView.topView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                SideMenuVCManager.shared.presentSideMenu()
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.isSideVCAppear)
            .bind(with: self) { owner, noti in
                if let show = noti.userInfo?["show"] as? Bool {
                    owner.mainView.alphaView.isHidden = !show
                }
            }
            .disposed(by: disposeBag)
        
    }
}
