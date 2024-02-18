//
//  NoMemberDmView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit

final class NoMemberDmView: BaseView {
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 19
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private let noMemberTitleLabel = CustomBasicLabel(text: Text.noMemberDmTitle, fontType: .title1, line: 2).then {
        $0.textAlignment = .center
    }
    private let noMemberMsgLabel = CustomBasicLabel(text: Text.noMemberDmMsg, fontType: .body, line: 1).then {
        $0.textAlignment = .center
    }
    let inviteMemberButton = CustomButton(bgColor: .brand, title: Text.inviteMember)
    
    
    override func configure() {
//        super.configure()
        backgroundColor = .secondaryBackground
        addSubview(stackView)
        [noMemberTitleLabel, noMemberMsgLabel, inviteMemberButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
    }
    
    override func setConstraints() {
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        noMemberMsgLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        
        inviteMemberButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    
}
