//
//  EmailLoginView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit

final class EmailLoginView: BaseView {
    
    let emailInput = CommonFormView(title: "이메일", placeholder: "이메일을 입력하세요.", keyboardType: .emailAddress)
    let passwordInput = CommonFormView(title: "비밀번호", placeholder: "비밀번호를 입력하세요.").then {
        $0.textfield.isSecureTextEntry = true
    }
    
    let loginButton = CustomButton(bgColor: .inactive, title: "로그인").then {
        $0.isEnabled = false
    }
    
    override func configure() {
        super.configure()
        [emailInput, passwordInput, loginButton].forEach {
            addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        
        emailInput.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
        }
        passwordInput.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(emailInput.snp.bottom).offset(24)
        }
        
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(Constants.Design.buttonHeight)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-24)
        }
        
    }
    
    func setEmailValidColor(valid: Bool) {
        emailInput.titleLabel.textColor = valid ? Constants.Color.basicText : Constants.Color.error
    }
    func setPasswordValidColor(valid: Bool) {
        passwordInput.titleLabel.textColor = valid ? Constants.Color.basicText : Constants.Color.error
    }
    
    func setButtonValid(valid: Bool) {
        loginButton.isEnabled = valid
        loginButton.backgroundColor = valid ? Constants.Color.mainColor : Constants.Color.inActive
    }
    
    
    
    
}
