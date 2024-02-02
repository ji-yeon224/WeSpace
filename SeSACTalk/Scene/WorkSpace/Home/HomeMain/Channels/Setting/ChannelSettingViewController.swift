//
//  ChannelSettingViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import UIKit
import ReactorKit

final class ChannelSettingViewController: BaseViewController {
    
    private let mainView = ChannelSettingView()
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        super.configure()
        configNav()
        title = "채널 설정"
        mainView.configDummyData()
        mainView.setButtonHidden(isAdmin: true)
    }
    
    
    
    
}

extension ChannelSettingViewController {
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
