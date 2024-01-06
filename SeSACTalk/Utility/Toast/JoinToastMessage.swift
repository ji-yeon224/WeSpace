//
//  JoinToastMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/5/24.
//

import Foundation

enum JoinToastMessage {
    case emailValidationError
    case validEmail
    case alreadyValid
    case notCheckEmail
    case nickConditionError
    case phoneValidError
    case passwordValidError
    case notEqualPassword
    case existAccount
    case others
    
    var message: String {
        switch self {
        case .emailValidationError:
            return "이메일 형식이 올바르지 않습니다. "
        case .validEmail, .alreadyValid:
            return "사용 가능한 이메일입니다. "
        case .notCheckEmail:
            return "이메일 중복 확인을 진행해주세요. "
        case .nickConditionError:
            return "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
        case .phoneValidError:
            return "잘못된 전화번호 형식입니다."
        case .passwordValidError:
            return "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
        case .notEqualPassword:
            return "작성하신 비밀번호가 일치하지 않습니다. "
        case .existAccount:
            return "이미 가입된 회원입니다. 로그인을 진행해주세요. "
        case .others:
            return "에러가 발생했어요. 잠시 후 다시 시도해주세요. "
        }
    }
}

