//
//  JoinView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit


final class JoinView: BaseView {
    
    private let emailView = CustomStackView()
    private let emailcheckView = UIView()
    
    private let nickNameView = CustomStackView()
    private let phoneView = CustomStackView()
    private let passwordView = CustomStackView()
    private let checkView = CustomStackView()
    
    private let emailLabel = CustomBasicLabel(text: "이메일", fontType: .title2)
    private let nickNameLabel = CustomBasicLabel(text: "닉네임", fontType: .title2)
    private let phoneLabel = CustomBasicLabel(text: "연락처", fontType: .title2)
    private let passwordLabel = CustomBasicLabel(text: "비밀번호", fontType: .title2)
    private let checkLabel = CustomBasicLabel(text: "비밀번호 확인", fontType: .title2)
    
    let emailTextField = {
        let view = CustomTextField(placeholder: "이메일을 입력하세요")
        view.keyboardType = UIKeyboardType.emailAddress
        return view
    }()
    
    let nickNameTextField = CustomTextField(placeholder: "닉네임을 입력하세요")
    let phoneTextField = CustomTextField(placeholder: "연락처를 입력하세요")
    let passwordTextField = CustomTextField(placeholder: "비밀번호를 입력하세요")
    let checkTextField = CustomTextField(placeholder: "비밀번호를 한 번 더 입력하세요")
    
    let emailCheckButton = CustomButton(bgColor: Constants.Color.inActive, title: "중복 확인")
    
    private let joinButtonView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.background
        return view
    }()
    private let seperator = {
        let view = UIView()
        view.backgroundColor = Constants.Color.seperator
        return view
    }()
    let joinButton = CustomButton(bgColor: Constants.Color.inActive, title: "가입하기")
    
    override func configure() {
        super.configure()
        
        emailCheckButton.isEnabled = false
        phoneTextField.delegate = self
        configChildView()
        [emailView, nickNameView, phoneView, passwordView, checkView, seperator, joinButtonView].forEach {
            addSubview($0)
        }
        [emailTextField, nickNameTextField, phoneTextField, passwordTextField, checkTextField].forEach {
            $0.delegate = self
        }
    }
    
    private func configChildView() {
        [emailTextField, emailCheckButton].forEach {
            emailcheckView.addSubview($0)
        }
        [emailLabel, emailcheckView].forEach {
            emailView.addArrangedSubview($0)
        }
        [nickNameLabel, nickNameTextField].forEach {
            nickNameView.addArrangedSubview($0)
        }
        [phoneLabel, phoneTextField].forEach {
            phoneView.addArrangedSubview($0)
        }
        [passwordLabel, passwordTextField].forEach {
            passwordView.addArrangedSubview($0)
        }
        [checkLabel, checkTextField].forEach {
            checkView.addArrangedSubview($0)
        }
        joinButtonView.addSubview(joinButton)
    }
    
    override func setConstraints() {
        
        emailView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
        }
        nickNameView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(emailView.snp.bottom).offset(24)
        }
        phoneView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(nickNameView.snp.bottom).offset(24)
        }
        passwordView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(phoneView.snp.bottom).offset(24)
        }
        checkView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(passwordView.snp.bottom).offset(24)
        }
        
        seperator.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self)
            make.height.equalTo(1)
            make.bottom.equalTo(joinButtonView.snp.top)
        }
        
        joinButtonView.snp.makeConstraints { make in
            make.height.equalTo(68)
            make.horizontalEdges.equalTo(self)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
        
        setChildViewConstraints()
    }
    
    private func setChildViewConstraints() {
        emailTextField.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(emailcheckView)
            make.width.equalTo(emailcheckView).multipliedBy(0.7)
        }
        emailCheckButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalTo(emailcheckView)
            make.leading.equalTo(emailTextField.snp.trailing).offset(12)
        }
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        emailcheckView.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        nickNameTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        
        phoneLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        
        checkLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        checkTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        joinButton.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
            make.centerY.equalTo(joinButtonView)
            make.horizontalEdges.equalTo(joinButtonView).inset(24)
        }
    }
    
    func setTitleValidColor(title: JoinInputValue, valid: Bool) {
        let color = valid ? Constants.Color.basicText : Constants.Color.error
        switch title {
        case .email:
            emailLabel.textColor = color
        case .nickname:
            nickNameLabel.textColor = color
        case .phone:
            phoneLabel.textColor = color
        case .password:
            passwordLabel.textColor = color
        case .check:
            checkLabel.textColor = color
        }
    }
    
    func keyboardFocus(field: JoinInputValue) {
        print(field)
        switch field {
        case .email:
            emailTextField.becomeFirstResponder()
        case .nickname:
            nickNameTextField.becomeFirstResponder()
        case .phone:
            phoneTextField.becomeFirstResponder()
        case .password:
            passwordTextField.becomeFirstResponder()
        case .check:
            checkTextField.becomeFirstResponder()
        }
    }
    
    
}

extension JoinView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextField:
            nickNameTextField.becomeFirstResponder()
        case self.nickNameTextField:
            phoneTextField.becomeFirstResponder()
        case self.phoneTextField:
            passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            checkTextField.becomeFirstResponder()
        case self.checkTextField:
            checkTextField.resignFirstResponder()
        default: break
        }
        return true
    }
    
    
}
