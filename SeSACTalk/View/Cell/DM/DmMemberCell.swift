//
//  DmMemberCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit

final class DmMemberCell: BaseCollectionViewCell {
    
    let profileImageView = SquareFillImageView(frame: .zero)
    let nickNameLabel = CustomBasicLabel(text: "", fontType: .body, line: 0).then {
        $0.textAlignment = .center
    }
    
    
    
    override func configure() {
        [profileImageView, nickNameLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        profileImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView).inset(16)
            make.height.equalTo(profileImageView.snp.width)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView)
            make.top.equalTo(profileImageView.snp.bottom).offset(4)
            make.bottom.equalTo(contentView)
        }
        
    }
    
    
}
