//
//  WorkspaceListView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/14/24.
//

import UIKit

final class WorkspaceListSettingView: BaseView {
    
    
    private let icon = UIImageView()
    private let titleLabel = CustomBasicLabel(text: "", fontType: .body, color: .secondaryText)
    
    init(img: UIImage, title: String) {
        super.init(frame: .zero)
        icon.image = img
        titleLabel.text = title
    }
    
    override func configure() {
        backgroundColor = .white
        addSubview(icon)
        addSubview(titleLabel)
    }
    
    override func setConstraints() {
        icon.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(18)
            make.size.equalTo(18)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(icon.snp.trailing).offset(16)
            make.trailing.equalTo(self)
        }
    }
    
    
}
