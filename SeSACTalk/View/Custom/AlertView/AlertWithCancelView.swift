//
//  AlertWithCancelView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/16/24.
//

import UIKit

final class AlertWithCancelView: BaseView {
    private let alertView = UIView().then {
        $0.backgroundColor = Constants.Color.secondaryBG
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let stackView = CustomStackView()
    
    let titleLabel = CustomBasicLabel(text: "", fontType: .title2).then {
        $0.textAlignment = .center
    }
    let messageLabel = CustomBasicLabel(text: "", fontType: .body, color: Constants.Color.secondaryText, line: 0).then {
        $0.textAlignment = .center
    }
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    let okButton = CustomButton(bgColor: .brand, title: "확인")
    let cancelButton = CustomButton(bgColor: .inactive, title: "취소")
    
    override func configure() {
        addSubview(alertView)
        alertView.addSubview(stackView)
        [titleLabel, messageLabel, buttonStackView].forEach {
            stackView.addArrangedSubview($0)
        }
        [cancelButton, okButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
    }
    
    override func setConstraints() {
        alertView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(alertView).inset(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
        
    }
}

