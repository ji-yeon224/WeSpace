//
//  JoinError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation
enum JoinError: String, Error {
    case existAccount
    case error
}

extension JoinError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .existAccount:
            return JoinToastMessage.existAccount.message
        case .error:
            return JoinToastMessage.others.message
        }
    }
}
