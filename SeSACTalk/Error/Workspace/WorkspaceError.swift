//
//  WSCreateError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation
enum WorkspaceError: String, Error {
    case E11
    case E12
    case E13
    case E14
    case E15
    case E21
}

extension WorkspaceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E11:
            return "요청에 문제가 발생하였습니다."
        case .E12:
            return "이미 존재하는 워크스페이스 이름입니다."
        case .E13:
            return "존재하지 않는 데이터입니다."
        case .E14:
            return "워크스페이스를 수정 권한이 없습니다."
        case .E15:
            return "관리자를 다른 멤버로 변경 후 나가실 수 있습니다."
        case .E21:
            return "새싹 코인이 부족합니다."
        }
    }
}
