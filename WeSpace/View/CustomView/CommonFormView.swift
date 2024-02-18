//
//  CommonFormView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit

final class CommonFormView: BaseView {
    
    private let backView = CustomStackView()
    var titleLabel = CustomBasicLabel(text: "", fontType: .title2)
    var textfield = CustomTextField(placeholder: "")
    
    init(title: String, placeholder: String, keyboardType: UIKeyboardType = .default) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.textfield.placeholder = placeholder
        self.textfield.keyboardType = keyboardType
    }
    
    override func configure() {
        backgroundColor = .clear
        addSubview(backView)
        backView.addArrangedSubview(titleLabel)
        backView.addArrangedSubview(textfield)
    }
    
    override func setConstraints() {
        backView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        textfield.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
        }
    }
    
    
}

