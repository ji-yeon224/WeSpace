//
//  DBImageFileName.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation

enum DBImageFileName {
    case channel(wsId: Int, channelId: Int)
    case dm(wsId: Int, roomId: Int)
}

extension DBImageFileName {
    var fileName: String {
        switch self {
        case .channel(let wsId, let channelId):
            return "\(wsId)_\(channelId)_"
        case .dm(let wsId, let roomId):
            return "\(wsId)_\(roomId)_"
        }
    }
}
