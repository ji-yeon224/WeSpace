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
    }
    
    override func configure() {
        super.configure()
        configNavBar()
    }
    
}

extension JoinViewController {
    private func configNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
       
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true)
    }
}
