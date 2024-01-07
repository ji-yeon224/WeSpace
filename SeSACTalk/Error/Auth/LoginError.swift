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
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        }
    }
}
