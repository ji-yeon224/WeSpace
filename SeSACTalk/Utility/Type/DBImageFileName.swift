//
//  DBImageFileName.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation

enum DBImageFileName {
    case channel(wsId: Int, channelId: Int)
}

extension DBImageFileName {
    var fileName: String {
        switch self {
        case .channel(let wsId, let channelId):
            return "\(wsId)_\(channelId)_"
        }
    }
}
