//
//  CustomButton.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

final class CustomButton: UIButton {
    
    
    init(bgColor: UIColor?, img: UIImage? = nil, titleColor: UIColor? = .white, title: String, radius: CGFloat = Constants.Design.cornerRadius) {
        super.init(frame: .zero)
        backgroundColor = bgColor
        setTitle(title, for: .normal)
        titleLabel?.font = Font.title2.fontStyle
        if let img = img {
            setImage(img, for: .normal)
        }
        
        setTitleColor(titleColor, for: .normal)
        layer.cornerRadius = radius
    }
    
    init(bgColor: UIColor?, borderColor: UIColor?, titleColor: UIColor? = .white, img: UIImage? = nil, title: String, radius: CGFloat = Constants.Design.cornerRadius) {
        super.init(frame: .zero)
        backgroundColor = bgColor
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = 1
        setTitle(title, for: .normal)
        titleLabel?.font = Font.title2.fontStyle
        if let img = img {
            setImage(img, for: .normal)
        }
        
        setTitleColor(titleColor, for: .normal)
        layer.cornerRadius = radius
    }
    
    init(image: UIImage?) {
        super.init(frame: .zero)
        
        setImage(image, for: .normal)
        imageView?.contentMode = .scaleAspectFit
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
