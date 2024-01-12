//
//  WorkspaceFetchError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation

enum WorkspaceFetchError: String, Error {
    case E13
    
}

extension WorkspaceFetchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E13:
            return "존재하지 않는 데이터입니다."
        }
    }
}
