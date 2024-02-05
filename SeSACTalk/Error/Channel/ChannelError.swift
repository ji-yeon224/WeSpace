//
//  ChannelChatError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
enum ChannelError: String, Error {
    case E11, E13, E14, E15
}

extension ChannelError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E11:
            return "요청에 문제가 발생하였습니다."
        case .E13:
            return "데이터에 문제가 발생하였습니다."
        case .E14:
            return "요청 권한이 없습니다."
        case .E15:
            return ""
        }
    }
    var exitErrorDescription: String? {
        switch self {
        case .E11:
            return "일반 채널은 워크스페이스 기본 채널입니다. 기본 채널은 퇴장할 수 없습니다."
        case .E13:
            return "데이터에 문제가 발생하였습니다."
        case .E14:
            return "요청 권한이 없습니다."
        case .E15:
            return "채널 관리자는 채널에 대한 권한을 양도 후 퇴장할 수 있습니다."
        }
    }
}
