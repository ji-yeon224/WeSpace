//
//  ChatWriteView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit

final class ChatWriteView: BaseView {
    
    
    let imageButton = CustomButton(image: .plus).then{
        $0.backgroundColor = .clear
    }
    
    let textView = UITextView().then {
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.font = Font.body.fontStyle
        $0.backgroundColor = Constants.Color.background
        $0.translatesAutoresizingMaskIntoConstraints = true
    
        
    }
    
    let placeholder = CustomBasicLabel(text: "메세지를 입력하세요.", fontType: .body, color: .secondaryText, line: 1)
   
    
    let sendButton = CustomButton(image: .sendInactive).then {
        $0.backgroundColor = .clear
    }
    override func configure() {
        layer.cornerRadius = 8
        
        backgroundColor = Constants.Color.background
        [imageButton, textView, sendButton].forEach {
            addSubview($0)
        }
        textView.addSubview(placeholder)
        
        
    }
    
    override func setConstraints() {
        
        imageButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(self).inset(10)
            make.size.equalTo(24)
            make.top.greaterThanOrEqualTo(self).inset(10)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(self).inset(10)
            make.size.equalTo(24)
            make.top.greaterThanOrEqualTo(self).inset(10)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.equalTo(imageButton.snp.trailing).offset(8)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.verticalEdges.equalTo(self).inset(10)
            make.height.lessThanOrEqualTo(54)
            make.height.greaterThanOrEqualTo(16)
        }
        placeholder.snp.makeConstraints { make in
            make.leading.equalTo(textView).offset(5)
            make.centerY.equalTo(textView)
        }
        
    }
    
    
}
