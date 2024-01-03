//
//  CustomBasicLabel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit

final class CustomBasicLabel: UILabel {
    
    init(text: String, fontType: Font, color: UIColor?, line: Int = 1) {
        super.init(frame: .zero)
        font = fontType.fontStyle
        textColor = color
        numberOfLines = line
        setTextWithLineHeight(text: text, fontType: fontType)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
