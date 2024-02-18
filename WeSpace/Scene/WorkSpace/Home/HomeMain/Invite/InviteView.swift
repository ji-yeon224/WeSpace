//
//  InviteView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/20/24.
//

import UIKit

final class InviteView: BaseView {
    
    let emailForm = CommonFormView(title: "이메일", placeholder: Text.inviteEmailPlaceholder, keyboardType: .emailAddress)
    
    let sendButton = CustomButton(bgColor: .inactive, title: "초대보내기")
    
    override func configure() {
        super.configure()
        addSubview(emailForm)
        addSubview(sendButton)
    }
    
    override func setConstraints() {
        emailForm.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        sendButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-10)
            make.height.equalTo(Constants.Design.buttonHeight)
        }
    }
    
    
}
