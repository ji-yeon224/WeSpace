//
//  LoginError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation

enum LoginError: String, Error {
    case E03
}

extension LoginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E03:
            return "로그인에 실패하였습니다."
        }
    }
}
