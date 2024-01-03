//
//  CustomButton.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

final class CustomButton: UIButton {
    
    
    init(bgColor: UIColor, title: String) {
        super.init(frame: .zero)
        backgroundColor = bgColor
        setTitleColor(Constants.Color.white, for: .normal)
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
