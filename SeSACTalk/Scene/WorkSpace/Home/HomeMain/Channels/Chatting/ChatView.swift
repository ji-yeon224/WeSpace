//
//  ChatView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit

final class ChatView: BaseView {
    
    private let bottomView = UIStackView().then {
        $0.backgroundColor = .white
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: .zero, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    let chatWriteView = ChatWriteView()
    
    override func configure() {
        backgroundColor = Constants.Color.secondaryBG
        
        addSubview(bottomView)
        bottomView.addArrangedSubview(chatWriteView)
//        addSubview(chatWriteView)
        
    }
    
    override func setConstraints() {
        
        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-8)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    
}
