//
//  JoinViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit
import RxSwift
import RxCocoa

final class JoinViewController: BaseViewController {
    
    private let mainView = JoinView()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "회원가입"
    }
    
    override func configure() {
        super.configure()
        configNavBar()
        view.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    
    
}



extension JoinViewController {
    private func configNavBar() {
        navigationController?.navigationBar.backgroundColor = Constants.Color.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
       
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true)
    }
}
