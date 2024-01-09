//
//  WorkspaceCollectionViewCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/9/24.
//

import UIKit

final class WorkspaceCollectionViewCell: BaseCollectionViewCell {
    var imageView = UIImageView().then {
        $0.image = .hashTagThin
    }
    
    let titleLabel = CustomBasicLabel(text: "", fontType: .body, color: .secondaryText, line: 1)
    let unreadView = UnreadCntView()
    
    override func configure() {
        
        [imageView, titleLabel, unreadView].forEach {
            addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.size.equalTo(18)
            make.leading.equalTo(self).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.height.equalTo(28)
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalTo(unreadView.snp.leading)
        }
        
        unreadView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-17)
        }
    }
}

