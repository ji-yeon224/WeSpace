//
//  InviteView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/20/24.
//

import UIKit

final class InviteView: BaseView {
    
    let emailForm = CommonFormView(title: "이메일", placeholder: Text.inviteEmailPlaceholder, keyboardType: .emailAddress)
    
    override func configure() {
        super.configure()
        addSubview(emailForm)
    }
    
    override func setConstraints() {
        emailForm.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
    }
    
    
}
