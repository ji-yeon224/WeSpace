//
//  ProfileImageView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit

final class ProfileImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image = .dummy
        
        contentMode = .scaleAspectFill
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = Constants.Color.secondaryText?.cgColor
    }
    
    
    
    
}
