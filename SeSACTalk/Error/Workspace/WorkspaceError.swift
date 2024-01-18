//
//  WorkspaceFetchError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation

enum WorkspaceError: String, Error {
    case E13
    case E15
}

extension WorkspaceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E13:
            return "존재하지 않는 데이터입니다."
        case .E15:
            return "관리자를 다른 멤버로 변경 후 나가실 수 있습니다."
        }
    }
}
