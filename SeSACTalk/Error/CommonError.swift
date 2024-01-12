//
//  CommonError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/4/24.
//

import Foundation

enum CommonError: String, Error {
    case E01
    case E97
    case E98
    case E99
}

extension CommonError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E01:
            return "접근 권한이 없습니다."
        case .E97:
            return "경로가 잘못되었습니다."
        case .E98:
            return "과호출"
        case .E99:
            return "서버에 문제가 발생하였습니다."
        }
    }
}
