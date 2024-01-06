//
//  EmailLoginView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit

final class EmailLoginView: BaseView {
    
    private let emailView = CustomStackView()
    private let passwordView = CustomStackView()
    
    private let emailLabel = CustomBasicLabel(text: "이메일", fontType: .title2)
    private let passwordLabel = CustomBasicLabel(text: "비밀번호", fontType: .title2)
    let emailTextField = CustomTextField(placeholder: "이메일을 입력하세요").then {
        $0.keyboardType = UIKeyboardType.emailAddress
    }
    let passwordTextField =  CustomTextField(placeholder: "비밀번호를 입력하세요").then {
        $0.isSecureTextEntry = true
    }
    
    let loginButton = CustomButton(bgColor: .inactive, title: "로그인").then {
        $0.isEnabled = false
    }
    
    override func configure() {
        super.configure()
        [emailView, passwordView, loginButton].forEach {
            addSubview($0)
        }
        
        [emailLabel, emailTextField].forEach { emailView.addArrangedSubview($0) }
        [passwordLabel, passwordTextField].forEach { passwordView.addArrangedSubview($0) }
        
        
    }
    
    override func setConstraints() {
        
        emailView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
        }
        passwordView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(emailView.snp.bottom).offset(24)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        passwordLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(Constants.Design.buttonHeight)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-24)
        }
        
    }
    
    func setEmailValidColor(valid: Bool) {
        emailLabel.textColor = valid ? Constants.Color.basicText : Constants.Color.error
    }
    func setPasswordValidColor(valid: Bool) {
        passwordLabel.textColor = valid ? Constants.Color.basicText : Constants.Color.error
    }
    
    func setButtonValid(valid: Bool) {
        loginButton.isEnabled = valid
        loginButton.backgroundColor = valid ? Constants.Color.green : Constants.Color.inActive
    }
    
    
    
    
}
