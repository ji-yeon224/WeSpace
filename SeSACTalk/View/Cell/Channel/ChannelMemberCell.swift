//
//  ChannelMemberCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import UIKit

final class ChannelMemberCell: BaseCollectionViewCell {
    
    private let backView = UIView()
    let profileImageView = SquareFillImageView(frame: .zero)
    let nameLabel = CustomBasicLabel(text: "", fontType: .body, line: 2).then {
        $0.textAlignment = .center
    }
    
    override func configure() {
        super.configure()
        [profileImageView, nameLabel].forEach { contentView.addSubview($0) }
        
    }
    
    override func setConstraints() {
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).inset(16)
            
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(contentView).inset(8)
            make.bottom.equalTo(contentView).inset(4)
        }
    }
    
}
