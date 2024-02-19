//
//  ProfileCell.swift
//  WeSpace
//
//  Created by 김지연 on 2/19/24.
//

import UIKit

final class ProfileCell: BaseCollectionViewCell {
    let cellTitle = CustomBasicLabel(text: "", fontType: .bodyBold)
    let subTitle =  CustomBasicLabel(text: "", fontType: .body, color: .secondaryText)
    
    override func configure() {
        super.configure()
        [cellTitle, subTitle].forEach { contentView.addSubview($0) }
        
    }
    
    override func setConstraints() {
        cellTitle.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(15)
            make.verticalEdges.equalTo(contentView).inset(13)
            make.height.equalTo(18)
//            make.centerY.equalTo(contentView)
        }
        subTitle.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(10)
            make.height.equalTo(22)
            make.centerY.equalTo(contentView)
        }
    }
}
