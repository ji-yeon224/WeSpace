//
//  ChattingCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/22/24.
//

import UIKit

final class ChattingCell: BaseCollectionViewCell {
    
    let profileImageView = UserProfileImageView(frame: .zero)
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 5
    }
    let nickNameLabel = CustomBasicLabel(text: "", fontType: .caption, line: 1)
    
    private let chatTextView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Constants.Color.inActive?.cgColor
        $0.backgroundColor = .secondaryBackground
    }
    let chatTextLabel = CustomBasicLabel(text: "", fontType: .body, line: 0)
    
    
    let timeLabel = CustomBasicLabel(text: "", fontType: .caption2, color: .secondaryText)
    
    override func configure() {
        [profileImageView, contentStackView, timeLabel].forEach {
            contentView.addSubview($0)
        }
        
        [nickNameLabel, chatTextView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        chatTextView.addSubview(chatTextLabel)
    }
    
    override func setConstraints() {
        
        let maxWidth: CGFloat = Constants.Design.deviceWidth * 0.6
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(34)
            make.leading.equalTo(contentView)
            make.top.equalTo(contentView).offset(6)
        }
        contentStackView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(6)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.width.lessThanOrEqualTo(maxWidth)
        }
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentStackView.snp.trailing).offset(8)
            make.bottom.equalTo(contentView).inset(6)
            make.trailing.greaterThanOrEqualTo(contentView).inset(14)
        }
        chatTextLabel.snp.makeConstraints { make in
            make.edges.equalTo(chatTextView).inset(8)
        }
        
    }
    
    
}
