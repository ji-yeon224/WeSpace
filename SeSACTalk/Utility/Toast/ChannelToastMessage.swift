//
//  ChannelToastMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import Foundation

enum ChannelToastMessage {
    case successCreate
    case loadFailChat
    case otherError
}

extension ChannelToastMessage {
    var message: String {
        switch self {
        case .successCreate:
            return "채널이 생성되었습니다."
        case .loadFailChat:
            return "채팅을 로드하는데 문제가 발생하였습니다."
        case .otherError:
            return "문제가 발생하였습니다."
        }
    }
}
