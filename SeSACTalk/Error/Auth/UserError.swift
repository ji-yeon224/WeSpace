//
//  UserError.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation
enum UserError: String, Error {
    case E03, E11
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E03:
            return "계정 정보를 불러올 수 없습니다."
        case .E11:
            return "요청에 문제가 발생하였습니다."
        }
    }
}
