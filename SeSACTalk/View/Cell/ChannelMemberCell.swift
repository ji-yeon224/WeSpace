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
    let nameLabel = CustomBasicLabel(text: "", fontType: .body, line: 0).then {
        $0.textAlignment = .center
    }
    
    override func configure() {
        super.configure()
        contentView.addSubview(backView)
        [profileImageView, nameLabel].forEach { backView.addSubview($0) }
        
    }
    
    override func setConstraints() {
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
            
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.centerX.equalTo(backView)
            make.top.horizontalEdges.equalTo(backView).inset(16)
            
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(backView).inset(8)
            make.bottom.greaterThanOrEqualTo(backView).inset(4)
        }
    }
    
}
