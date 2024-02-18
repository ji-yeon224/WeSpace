//
//  RefreshError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation

enum RefreshError: String, Error {
    case E02
    case E03
    case E04
    case E05
    case E06
    
}

extension RefreshError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E02:
            return "인증에 실패하였습니다. "
        case .E03:
            return "계정 정보를 확인할 수 없습니다."
        case .E04:
            return "유효한 토큰입니다."
        case .E05:
            return "엑세스 토큰이 만료되었습니다."
        case .E06:
            return "다시 로그인해주세요."
        
        }
    }
}
