//
//  EditProfileView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import UIKit

final class EditProfileView: BaseView {
    
    let editTextfield = CustomTextField(placeholder: "")
    let completeButton =  CustomButton(bgColor: .inactive, title: "완료").then {
        $0.isEnabled = false
    }
    
    override func configure() {
        super.configure()
        [editTextfield, completeButton].forEach {
            addSubview($0)
        }
    }
    
    override func setConstraints() {
        editTextfield.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(self).inset(24)
            make.height.equalTo(44)
        }
        
        completeButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(Constants.Design.buttonHeight)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-24)
        }
    }
    
    
    func setButtonEnable(isActive: Bool) {
        completeButton.isEnabled = isActive
        completeButton.backgroundColor = isActive ? .brand : .inactive
    }
    
    func configTextFieldData(type: EditProfileType, data: ProfileUpdateReqDTO) {
        switch type {
        case .editNickname:
            editTextfield.placeholder = "닉네임을 입력하세요."
            editTextfield.text = data.nickName
        case .editPhone:
            editTextfield.placeholder = "전화번호를 입력하세요."
            editTextfield.text = data.phone
        }
    }
    
}
