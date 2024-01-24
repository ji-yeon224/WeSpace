//
//  ChannelChatError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation

enum ChannelChatError: String, Error {
    case E11
    case E13
}

extension ChannelChatError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E11:
            return "요청에 문제가 발생하였습니다."
        case .E13:
            return "데이터가 존재하지 않습니다."
        }
    }
}
