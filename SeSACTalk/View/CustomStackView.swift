//
//  CustomStackView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit

final class CustomStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        axis = .vertical
        distribution = .fill
        spacing = 8
        isLayoutMarginsRelativeArrangement = true
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
