//
//  InviteError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/20/24.
//

import Foundation
enum InviteError: String, Error {
    case E03
    case E11
    case E12
    case E13
    case E14
}

extension InviteError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E03:
            return "존재하지 않는 계정입니다."
        case .E11:
            return "요청에 문제가 발생하였습니다."
        case .E12:
            return "이미 워크스페이스 멤버입니다."
        case .E13:
            return "존재하지 않는 계정입니다."
        case .E14:
            return "관리자 권한이 없습니다."
        }
    }
}
