//
//  ChatImageCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/22/24.
//

import UIKit

final class ChatImageCell: BaseCollectionViewCell {
    
    let imageView = SquareFillImageView(frame: .zero).then {
        $0.layer.cornerRadius =  8
        $0.backgroundColor = .secondaryBackground
    }
    let xButton = CircleButton(image: .close).then {
        $0.backgroundColor = .secondaryBackground
        $0.layer.borderColor = Constants.Color.basicText?.cgColor
        $0.layer.borderWidth = 1
    }
    
    
    override func configure() {
        contentView.backgroundColor = .clear
        [imageView, xButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.bottom.equalTo(contentView)
            make.width.equalTo(contentView).multipliedBy(0.9)
            make.height.equalTo(imageView.snp.width)
        }
        xButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView)
            make.width.equalTo(contentView).multipliedBy(0.3)
            make.height.equalTo(xButton.snp.width)
        }
        
        
    }
    
}
