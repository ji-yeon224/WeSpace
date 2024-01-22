//
//  UserProfileImageView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/22/24.
//

import UIKit

final class UserProfileImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        image = .dummy
        
        contentMode = .scaleAspectFill
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
