//
//  ChatTableViewCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit

final class ChatTableViewCell: BaseTableViewCell {
    
    
    let profileImageView = SquareFillImageView(frame: .zero)
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 5
    }
    let nickNameLabel = CustomBasicLabel(text: "", fontType: .caption, line: 1)
    
    lazy var chatMsgView = UIView().then {
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    let chatTextView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Constants.Color.inActive?.cgColor
        $0.backgroundColor = .secondaryBackground
    }
    let chatTextLabel = CustomBasicLabel(text: "", fontType: .body, line: 0)
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.isHidden = true
    }
    
    private var chatImgView = ImageMessageView().then {
        $0.isHidden = true
    }
    private let dateLabel = CustomBasicLabel(text: "", fontType: .caption2, color: .secondaryText)
    private let timeLabel = CustomBasicLabel(text: "", fontType: .caption2, color: .secondaryText)
    
    override func configure() {
        [profileImageView, contentStackView, dateLabel, timeLabel].forEach {
            contentView.addSubview($0)
        }
        
        [nickNameLabel, chatMsgView, stackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        stackView.addArrangedSubview(chatImgView)
        chatMsgView.addSubview(chatTextView)
        chatTextView.addSubview(chatTextLabel)
    }
    
    override func setConstraints() {
        
        let maxWidth: CGFloat = Constants.Design.deviceWidth * 0.6
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(34)
            make.leading.equalTo(contentView)
            make.top.equalTo(contentView).offset(10)
        }
        contentStackView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.width.lessThanOrEqualTo(maxWidth)
        }
        nickNameLabel.snp.makeConstraints { make in
//            make.height.equalTo(18)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentStackView.snp.trailing).offset(8)
            make.bottom.equalTo(timeLabel.snp.top).offset(-3)
//            make.trailing.greaterThanOrEqualTo(contentView).inset(14)
        }
        
        timeLabel.snp.makeConstraints { make in
//            make.top.equalTo(contentView)
            make.leading.equalTo(contentStackView.snp.trailing).offset(8)
            make.bottom.equalTo(contentView).inset(10)
            make.trailing.greaterThanOrEqualTo(contentView).inset(14)
        }
        chatTextView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(chatMsgView)
            make.trailing.lessThanOrEqualTo(chatMsgView.snp.trailing)
        }
        chatTextLabel.snp.makeConstraints { make in
            make.edges.equalTo(chatTextView).inset(8)
            make.height.greaterThanOrEqualTo(18)
        }
        
        chatImgView.snp.makeConstraints { make in
            make.width.equalTo(maxWidth)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        chatImgView.isHidden = false
        stackView.isHidden = false
        chatImgView.initImageView()
        chatMsgView.isHidden = false
        chatTextLabel.text = nil
        dateLabel.isHidden = false
    }
    
    func configImage(files: [String]) {
        chatImgView.configImage(files: files)
    }
    func configUIImage(imgs: [UIImage]) {
        chatImgView.configUIImage(img: imgs)
    }
    
    func setImageViewHidden(hidden: Bool) {
        chatImgView.isHidden = hidden
        stackView.isHidden = hidden
    }
    
    func setTimeLabel(date: String) {
        timeLabel.text = date.convertToTimeString
        if !Date.isTodayDate(compareDate: date) {
            dateLabel.text = date.convertToDateString
        } else {
            dateLabel.isHidden = true
        }
    }
    
}
