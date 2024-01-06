//
//  EmailLoginViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit
import RxSwift
import RxCocoa

final class EmailLoginViewController: BaseViewController {
    
    private let mainView = EmailLoginView()
    private let viewModel = EmailLoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "이메일 로그인"
    }
    
    override func configure() {
        super.configure()
        
    }
    
    func bind() {
        
    }
    
    
}
