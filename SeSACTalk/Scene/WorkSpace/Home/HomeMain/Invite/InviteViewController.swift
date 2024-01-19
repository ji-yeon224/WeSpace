//
//  InviteViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/20/24.
//

import UIKit

final class InviteViewController: BaseViewController {
    
    private let mainView = InviteView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configure() {
        super.configure()
        title = "팀원 초대"
        configNav()
        mainView.emailForm.textfield.becomeFirstResponder()
    }
    
}

extension InviteViewController {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}
