//
//  DmError.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import Foundation

enum DmError: String, Error {
    case E11, E13
}

extension DmError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E11:
            return "요청에 문제가 발생하였습니다."
        case .E13:
            return "데이터에 문제가 발생하였습니다."
        }
    }
}
