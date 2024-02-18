//
//  InfoViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import UIKit
import SnapKit

final class InfoViewController: BaseViewController {
    
    private let accesstoken = CustomButton(bgColor: .brand, title: "access")
    private let refreshtoken = CustomButton(bgColor: .brand, title: "refresh")
    private let logout = CustomButton(bgColor: .brand, title: "logout")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configure() {
        super.configure()
        
        view.addSubview(accesstoken)
        view.addSubview(refreshtoken)
        view.addSubview(logout)
        
        accesstoken.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(100)
            make.height.equalTo(50)
            make.width.equalTo(100)
        }
        refreshtoken.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(accesstoken.snp.bottom).offset(100)
            make.height.equalTo(50)
            make.width.equalTo(100)
        }
        logout.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(refreshtoken.snp.bottom).offset(100)
            make.height.equalTo(50)
            make.width.equalTo(100)
        }
        
        accesstoken.addTarget(self, action: #selector(accesstokenBtn), for: .touchUpInside)
        refreshtoken.addTarget(self, action: #selector(refreshtokenBtn), for: .touchUpInside)
        logout.addTarget(self, action: #selector(logoutBtn), for: .touchUpInside)
        
    }
    
    @objc private func accesstokenBtn() {
        print("ACCESS TOKEN:  ", UserDefaultsManager.accessToken)
    }
    @objc private func refreshtokenBtn() {
        print("REFRESH TOKEN  ", UserDefaultsManager.refreshToken)
    }
    @objc private func logoutBtn() {
        UserDefaultsManager.initToken()
        view?.window?.rootViewController = OnBoardingViewController()
        view.window?.makeKeyAndVisible()
    }
    
    
}
