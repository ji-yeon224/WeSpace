//
//  EditImageView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit

final class EditImageView: BaseView {
    
    private let backView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let imageView = UIImageView().then {
        $0.image = .workspace
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .brand
        $0.layer.cornerRadius = 8
    }
    private let cameraView = UIImageView().then {
        $0.image = .camera
        $0.backgroundColor = .clear
        
    }
    
    override func configure() {
        addSubview(backView)
        backView.addSubview(imageView)
        backView.addSubview(cameraView)
    }
    
    override func setConstraints() {
        backView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalTo(self)
            make.size.equalTo(70)
            
        }
        cameraView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.bottom.equalTo(self)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cameraView.layer.cornerRadius = cameraView.frame.height/2
        cameraView.clipsToBounds = true
    }
    
}
