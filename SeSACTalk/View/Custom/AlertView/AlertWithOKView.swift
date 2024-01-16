//
//  AlertWithOKView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/16/24.
//

import UIKit

final class AlertWithOKView: BaseView {
    
    private let alertView = UIView().then {
        $0.backgroundColor = Constants.Color.secondaryBG
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let stackView = CustomStackView().then {
        $0.spacing = 10
    }
    
    let titleLabel = CustomBasicLabel(text: "", fontType: .title2).then {
        $0.textAlignment = .center
    }
    let messageLabel = CustomBasicLabel(text: "", fontType: .body, color: Constants.Color.secondaryText, line: 0).then {
        $0.textAlignment = .center
    }
    
    let okButton = CustomButton(bgColor: .brand, title: "확인")
    
    override func configure() {
        addSubview(alertView)
        alertView.addSubview(stackView)
        [titleLabel, messageLabel, okButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    override func setConstraints() {
        alertView.snp.makeConstraints { make in
//            make.centerX.equalTo(safeAreaLayoutGuide)
//            make.horizontalEdges.equalToSuperview().inset(24)
            make.edges.equalTo(self)
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(alertView).inset(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        okButton.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        
    }
    
    
    
}
