//
//  DmChatCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit

final class DmChatCell: BaseCollectionViewCell {
    
    let profileImageView = SquareFillImageView(frame: .zero)
    let nickNameLabel = CustomBasicLabel(text: "", fontType: .body, line: 1)
    let messagelabel = CustomBasicLabel(text: "", fontType: .body, color: .secondaryText, line: 2)
    let timeLabel = CustomBasicLabel(text: "", fontType: .body, color: .secondaryText, line: 1)
    let unreadView = UnreadCntView().then {
        $0.isHidden = true
    }
    
    override func configure() {
        contentView.backgroundColor = .secondaryBackground
        [profileImageView, nickNameLabel, messagelabel, timeLabel, unreadView].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(34)
            make.leading.equalTo(contentView).inset(16)
            make.top.equalTo(contentView).inset(6)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.top.equalTo(contentView).inset(6)
        }
        
        messagelabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(6)
            make.height.equalTo(18)
            make.trailing.equalTo(contentView).inset(16)
        }
        
        unreadView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom)
            make.trailing.equalTo(contentView).inset(16)
            make.leading.equalTo(messagelabel.snp.trailing)
        }
    }
    
    
}
