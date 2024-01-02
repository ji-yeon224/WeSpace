//
//  UILabel+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit

extension UILabel {
    func setTextWithLineHeight(text: String?, fontType: Font) {
        
        if let text = text {
            let style = NSMutableParagraphStyle()
            let lineHeight = fontType.lineHeight
            
            style.maximumLineHeight = lineHeight
            style.minimumLineHeight = lineHeight
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: style,
                .baselineOffset: (lineHeight - font.lineHeight) / 2
            ]
            
            let attrString = NSAttributedString(string: text,
                                                attributes: attributes)
            self.attributedText = attrString
        }
    }
}
