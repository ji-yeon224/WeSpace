//
//  EmailError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/4/24.
//

import Foundation

enum EmailError: String, Error {
    case E11
    case E12
    
}

extension EmailError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E11:
            "잘못된 요청입니다."
        case .E12:
            "중복된 이메일입니다."
        }
    }
}
