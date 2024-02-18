//
//  DmToastMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/11/24.
//

import Foundation

enum DmToastMessage {
    case loadFailDm
    case otherError
}

extension DmToastMessage {
    var message: String {
        switch self {
        case .loadFailDm:
            return "dm 목록을 로드하는데 문제가 발생하였습니다."
        case .otherError:
            return "문제가 발생하였습니다."
        }
    }
}
