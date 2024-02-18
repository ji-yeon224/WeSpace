//
//  ChannelTableViewCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class ChannelTableViewCell: BaseTableViewCell {
    
    var hashTag = UIImageView().then {
        $0.image = .hashTagThin
    }
    
    let titleLabel = CustomBasicLabel(text: "", fontType: .body, color: .secondaryText, line: 1)
    let unreadView = UnreadCntView()
    
    override func configure() {
        
        [hashTag, titleLabel, unreadView].forEach {
            addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        hashTag.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.size.equalTo(18)
            make.leading.equalTo(self).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.height.equalTo(28)
            make.leading.equalTo(hashTag.snp.trailing)
            make.trailing.equalTo(unreadView.snp.leading)
        }
        
        unreadView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-17)
        }
    }
    
}
