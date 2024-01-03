//
//  CustomButton.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

final class CustomButton: UIButton {
    
    
    init(bgColor: UIColor?, title: String, radius: CGFloat = Constants.Design.cornerRadius) {
        super.init(frame: .zero)
        backgroundColor = bgColor
        setTitle(title, for: .normal)
        titleLabel?.font = Font.title2.fontStyle
        
        setTitleColor(Constants.Color.white, for: .normal)
        layer.cornerRadius = radius
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
