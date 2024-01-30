//
//  SearchChannelCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import UIKit

final class SearchChannelCell: BaseTableViewCell {
    
    private let hashtagImg = UIImageView().then {
        $0.image = .hashTagThick
    }
    
    let channelNameLabel = CustomBasicLabel(text: "", fontType: .bodyBold, line: 1)
    
    override func configure() {
        super.configure()
        [hashtagImg, channelNameLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        hashtagImg.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.size.equalTo(18)
            make.leading.equalTo(contentView).inset(16)
        }
        
        channelNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(hashtagImg.snp.trailing).offset(16)
            make.trailing.equalTo(contentView).inset(40)
        }
    }
    
}
