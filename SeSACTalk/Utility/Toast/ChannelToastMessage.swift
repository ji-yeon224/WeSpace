//
//  ChannelToastMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import Foundation

enum ChannelToastMessage {
    case successCreate
}

extension ChannelToastMessage {
    var message: String {
        switch self {
        case .successCreate:
            return "채널이 생성되었습니다."
        }
    }
}
