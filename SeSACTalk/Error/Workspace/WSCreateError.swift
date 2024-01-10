//
//  WSCreateError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation
enum WSCreateError: String, Error {
    case E11
    case E12
    case E21
}

extension WSCreateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E11:
            return "요청에 문제가 발생하였습니다."
        case .E12:
            return "이미 존재하는 워크스페이스 이름입니다."
        case .E21:
            return "새싹 코인이 부족합니다."
        }
    }
}
