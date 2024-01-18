//
//  MemberCollectionViewCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import UIKit

final class MemberCollectionViewCell: BaseCollectionViewCell {
    
    let backView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let memberImageView = UIImageView().then {
//        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
    }
    
    let memberNameLabel = CustomBasicLabel(text: "", fontType: .bodyBold, line: 1)
    let emailLabel = CustomBasicLabel(text: "'", fontType: .body, color: .secondaryText)
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        memberImageView.image = nil
        
        
    }
    
    override func configure() {
        contentView.addSubview(backView)
        
        [memberNameLabel, emailLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [memberImageView, stackView].forEach {
            backView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(5)
            
        }
        
        memberImageView.snp.makeConstraints { make in
            make.centerY.equalTo(backView)
            make.size.equalTo(44)
            make.leading.equalTo(backView.snp.leading).offset(8)
        }
        
        memberNameLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        stackView.snp.makeConstraints { make in
//            make.verticalEdges.equalTo(backView).inset(12)
            make.centerY.equalTo(backView)
            make.leading.equalTo(memberImageView.snp.trailing).offset(8)
            make.trailing.equalTo(backView).offset(-8)
        }
    }
    
}


