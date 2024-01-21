//
//  CreateChannelView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit

final class CreateChannelView: BaseView {
    
    let nameForm = CommonFormView(title: "채널 이름", placeholder: Text.createChannelNamePlaceholder)
    let descriptionForm = CommonFormView(title: "채널 설명", placeholder: Text.createChannelDescrptionPlaceholder)
    
    let createButton = CustomButton(bgColor: .inactive, title: "생성")
    
    override func configure() {
        super.configure()
        [nameForm, descriptionForm, createButton].forEach {
            addSubview($0)
        }
    }
    
    override func setConstraints() {
        nameForm.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(self).inset(24)
            
        }
        
        descriptionForm.snp.makeConstraints { make in
            make.top.equalTo(nameForm.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(self).inset(24)
        }
        
        createButton.snp.makeConstraints { make in
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-12)
            make.horizontalEdges.equalTo(self).inset(24)
        }
    }
    
}
