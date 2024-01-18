//
//  MemberCollectionViewCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import UIKit

final class MemberCollectionViewCell: BaseCollectionViewCell {
    
    
    
    let backView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .secondaryBackground
    }
    
    let workspaceImageView = UIImageView().then {
//        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
    }
    
    let workspaceName = CustomBasicLabel(text: "", fontType: .bodyBold, line: 1)
    let dateLabel = CustomBasicLabel(text: "'", fontType: .body, color: .secondaryText)
    
    let menuButton = CustomButton(image: Constants.Image.dot).then {
        $0.tintColor = .basicText
        $0.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backView.backgroundColor = .secondaryBackground
        menuButton.isHidden = true
        
    }
    
    override func configure() {
        contentView.addSubview(backView)
        
        [workspaceName, dateLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [workspaceImageView, stackView, menuButton].forEach {
            backView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(5)
            
        }
        
        workspaceImageView.snp.makeConstraints { make in
            make.centerY.equalTo(backView)
            make.size.equalTo(44)
            make.leading.equalTo(backView.snp.leading).offset(8)
        }
        
        workspaceName.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        dateLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        stackView.snp.makeConstraints { make in
//            make.verticalEdges.equalTo(backView).inset(12)
            make.centerY.equalTo(backView)
            make.leading.equalTo(workspaceImageView.snp.trailing).offset(8)
            make.trailing.equalTo(menuButton.snp.leading).offset(-8)
        }
        menuButton.snp.makeConstraints { make in
            make.trailing.equalTo(backView).offset(-12)
//            make.verticalEdges.equalTo(backView).inset(10)
            make.centerY.equalTo(backView)
            make.size.equalTo(20)
        }
        
        
    }
    
}


