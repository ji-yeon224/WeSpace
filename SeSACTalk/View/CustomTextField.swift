//
//  CustomTextField.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit

final class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 0.0))
        rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 0.0))
        layer.cornerRadius = Constants.Design.cornerRadius
        backgroundColor = Constants.Color.secondaryBG
        textColor = Constants.Color.basicText
        font = Font.body.fontStyle
        leftViewMode = .always
        rightViewMode = .always
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
