//
//  LoginToastMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import Foundation

enum LoginToastMessage {
    case invalidEmail
    case invalidPassword
    case other
}

extension LoginToastMessage {
    var message: String {
        switch self {
        case .invalidEmail:
            return "이메일 형식이 올바르지 않습니다."
        case .invalidPassword:
            return "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
        case .other:
            return "에러가 발생했어요. 잠시후 다시 시도해주세요."
        }
    }
}
