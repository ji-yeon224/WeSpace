//
//  HomeTopView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit

final class HomeTopView: BaseView {
    
    let wsImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = .seSACBot
        $0.layer.cornerRadius = 8
    }
    
    let workSpaceName = CustomBasicLabel(text: "No Workspace", fontType: .title1, line: 1)
    
    let profileImageView = ProfileImageView(frame: .zero)
    private let divider = UIView().then {
        $0.backgroundColor = .seperator
    }
    override func configure() {
        backgroundColor = .white
        [wsImageView, workSpaceName, profileImageView, divider].forEach {
            addSubview($0)
        }
    }
    
    override func setConstraints() {
        wsImageView.snp.makeConstraints { make in
//            make.centerY.equalTo(self)
            make.size.equalTo(32)
            make.leading.equalTo(self).inset(16)
            make.bottom.equalTo(-14)
        }
        workSpaceName.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.leading.equalTo(wsImageView.snp.trailing).offset(8)
            make.bottom.equalTo(-14)
        }
        profileImageView.snp.makeConstraints { make in
//            make.centerY.equalTo(self)
            make.height.equalTo(32)
            make.width.equalTo(profileImageView.snp.height)
            make.trailing.equalTo(self).offset(-16)
            make.leading.equalTo(workSpaceName.snp.trailing).offset(12)
            make.bottom.equalTo(-14)
            
        }
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self)
        }
    }
    
}

