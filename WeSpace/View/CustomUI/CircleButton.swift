//
//  CircleButton.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/22/24.
//

import UIKit

final class CircleButton: UIButton {
    
    init(image: UIImage) {
        super.init(frame: .zero)
        
        let config = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        self.tintColor = .black
        setImage(image, for: .normal)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
