//
//  LoginView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit

final class LoginView: BaseView {
    
    let appleButton = CustomButton(image: Constants.Image.appleLogin)
    let kakaoButton = CustomButton(image: Constants.Image.kakaoLogin)
    let emailButton = CustomButton(bgColor: Constants.Color.green, img: Constants.Image.email, title: "이메일로 계속하기")
    let joinLabel = {
        let view = CustomBasicLabel(text: "또는 새롭게 회원가입 하기", fontType: .title2, color: Constants.Color.green)
        let attributedStr = NSMutableAttributedString(string: view.text!)
        attributedStr.addAttribute(.foregroundColor, value: Constants.Color.black, range: (view.text! as NSString).range(of:"또는"))
        view.attributedText = attributedStr
        view.textAlignment = .center
        return view
    }()
    
    override func configure() {
        super.configure()
        addSubview(appleButton)
        addSubview(kakaoButton)
        addSubview(emailButton)
        addSubview(joinLabel)
        
    }
    
    override func setConstraints() {
        appleButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(35)
            make.height.equalTo(44)
            make.top.equalToSuperview().inset(42)
            
        }
        kakaoButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(35)
            make.height.equalTo(44)
            make.top.equalTo(appleButton.snp.bottom).offset(16)
        }
        emailButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(35)
            make.height.equalTo(44)
            make.top.equalTo(kakaoButton.snp.bottom).offset(16)
        }
        joinLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(35)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.top.equalTo(emailButton.snp.bottom).offset(14)
        }
        
    }
    
}
