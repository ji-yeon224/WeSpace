//
//  Font.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit


enum Font {
    case title1
    case title2
    case bodyBold
    case body
    case caption
    
    var fontStyle: UIFont {
        switch self {
        case .title1:
            return Constants.Design.title1Font
        case .title2:
            return Constants.Design.title2Font
        case .bodyBold:
            return Constants.Design.bodyBold
        case .body:
            return Constants.Design.body
        case .caption:
            return Constants.Design.caption
        }
    }
    var lineHeight: CGFloat {
        switch self {
        case .title1:
            return 30
        case .title2:
            return 20
        case .bodyBold, .body, .caption:
            return 18
        }
    }
}
