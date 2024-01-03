//
//  CommonError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/4/24.
//

import Foundation

enum CommonError: Error {
    case E01
    case E99
}

extension CommonError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E01:
            return "접근 권한이 없습니다."
        case .E99:
            return "서버에 문제가 발생하였습니다."
        }
    }
}
