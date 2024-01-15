//
//  Design.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

extension Constants {
    enum Design {
        static let cornerRadius: CGFloat = 8
        static let buttonHeight: CGFloat = 44
        static let deviceWidth: CGFloat = UIScreen.main.bounds.size.width
        
        static let title1Font: UIFont = UIFont(name: "SFPro-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        static let title2Font: UIFont = UIFont(name: "SFPro-Bold", size: 14) ?? .systemFont(ofSize: 14, weight: .bold)
        static let bodyBold: UIFont = UIFont(name: "SFPro-Bold", size: 13) ?? .systemFont(ofSize: 13, weight: .bold)
        static let body: UIFont = UIFont(name: "SFPro-Regular", size: 13) ?? .systemFont(ofSize: 13)
        static let caption: UIFont = UIFont(name: "SFPro-Regular", size: 12) ?? .systemFont(ofSize: 12)
    }
}
