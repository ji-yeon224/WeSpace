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
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    let titleLabel = CustomBasicLabel(text: "", fontType: .body, color: .secondaryText, line: 1)
    let unreadView = UnreadCntView().then {
        $0.isHidden = true
    }
    
    override func configure() {
        
        [imageView, titleLabel, unreadView].forEach {
            addSubview($0)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setInit()
        unreadView.isHidden = true
    }
    
    override func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.size.equalTo(18)
            make.leading.equalTo(self).offset(18)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.height.equalTo(28)
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(unreadView.snp.leading)
        }
        
        unreadView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-17)
        }
    }
    
    func setBold() {
        titleLabel.font = Font.bodyBold.fontStyle
        titleLabel.textColor = .basicText
        imageView.image = .hashTagThick
    }
    
    func setInit() {
        titleLabel.font = Font.body.fontStyle
        titleLabel.textColor = .secondaryText
        imageView.image = .hashTagThin
    }
    
    func setDmBold() {
        titleLabel.font = Font.bodyBold.fontStyle
        titleLabel.textColor = .basicText
    }
    func setDmThin() {
        titleLabel.font = Font.body.fontStyle
        titleLabel.textColor = .secondaryText
    }
}

