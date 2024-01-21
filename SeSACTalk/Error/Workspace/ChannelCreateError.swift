//
//  ChannelCreateError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import Foundation

enum ChannelCreateError: String, Error {
    case E11, E12, E13
}

extension ChannelCreateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E11: return "요청에 문제가 발생하였습니다."
        case .E12:
            return "워크스페이스에 이미 있는 채널 이름입니다. 다른 이름을 입력해주세요. "
        case .E13:
            return "존재하지 않는 데이터입니다."
        }
    }
}
