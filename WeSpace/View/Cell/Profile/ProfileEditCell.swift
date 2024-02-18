//
//  ProfileEditCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/13/24.
//

import UIKit

final class ProfileEditCell: BaseCollectionViewCell {
    
    let cellTitle = CustomBasicLabel(text: "", fontType: .bodyBold)
    let coinCountLabel = CustomBasicLabel(text: "", fontType: .bodyBold, color: .brand).then {
        $0.isHidden = true
    }
    private let rightChevron = UIImageView().then {
        $0.image = .right
        $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .secondaryText
        $0.backgroundColor = .secondaryBackground
        $0.isHidden = true
    }
    let subTitle =  CustomBasicLabel(text: "", fontType: .body, color: .secondaryText).then {
        $0.isHidden = true
    }
    let emailLabel = CustomBasicLabel(text: "", fontType: .body, color: .secondaryText).then {
        $0.isHidden = true
    }
    let socialImage = UIImageView().then {
        $0.isHidden = true
    }
    
    override func configure() {
        super.configure()
        contentView.backgroundColor = .secondaryBackground
        [cellTitle, coinCountLabel, rightChevron, subTitle, emailLabel, socialImage].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinCountLabel.isHidden = true
        rightChevron.isHidden = true
        subTitle.isHidden = true
        emailLabel.isHidden = true
        socialImage.isHidden = true
    }
    
    override func setConstraints() {
        
        cellTitle.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(15)
            make.verticalEdges.equalTo(contentView).inset(13)
            make.height.equalTo(18)
//            make.centerY.equalTo(contentView)
        }
        coinCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(cellTitle.snp.trailing).offset(5)
            make.verticalEdges.equalTo(contentView).inset(13)
        }
        rightChevron.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(12)
            make.size.equalTo(14)
            make.centerY.equalTo(contentView)
            
        }
        subTitle.snp.makeConstraints { make in
            make.trailing.equalTo(rightChevron.snp.leading).offset(-10)
            make.height.equalTo(22)
            make.centerY.equalTo(contentView)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(12)
            make.centerY.equalTo(contentView)
        }
        
        socialImage.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.trailing.equalTo(contentView).inset(14)
            make.centerY.equalTo(contentView)
        }
    }
    
    
    func setCellLayout(type: MyProfileEditType) {
        switch type {
        case .coin:
            coinCountLabel.isHidden = false
            rightChevron.isHidden = false
            subTitle.isHidden = false
            subTitle.text = "충전하기"
        case .nickname:
            rightChevron.isHidden = false
            subTitle.isHidden = false
        case .phone:
            rightChevron.isHidden = false
            subTitle.isHidden = false
        case .email:
            emailLabel.isHidden = false
        case .linkSocial:
            socialImage.isHidden = false
        case .logout:
            break
        }
    }
    
}
