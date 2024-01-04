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
    private let viewModel = JoinViewModel()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "회원가입"
        bind()
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
    
    private func bind() {
        
        let input = JoinViewModel.Input(
            emailValue: mainView.emailTextField.rx.text.orEmpty,
            nickNameValue: mainView.nickNameTextField.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.checkButtonEnable
            .asDriver()
            .drive(with: self) { owner, value in
                owner.mainView.emailCheckButton.isEnabled = value
                owner.mainView.emailCheckButton.backgroundColor = value ? Constants.Color.green : Constants.Color.inActive
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
