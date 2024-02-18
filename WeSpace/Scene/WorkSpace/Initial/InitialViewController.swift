//
//  InitialViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit

final class InitialViewController: BaseViewController {
    
    private let mainView = InitialView()
    
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "시작하기"
        configNav()
    }
    
    override func configure() {
        super.configure()
    }
    
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .basicText
    }
    
    @objc func xButtonTapped() {
        let vc = HomeEmptyViewController()
        let nav = UINavigationController(rootViewController: vc)
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
    }
    
}
