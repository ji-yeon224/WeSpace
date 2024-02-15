//
//  SocketURL.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/31/24.
//

import Foundation

enum SocketURL {
    case channel(chId: Int)
    case dm(roomId: Int)
    
   
    
    var nameSpace: String {
        switch self {
        case .channel(let chId):
            return "/ws-channel-\(chId)"
        case .dm(let roomId):
            return "/ws-dm-\(roomId)"
        }
    }
    
    
    var url: URL {
        return URL(string: BaseURL.baseURL + self.nameSpace)!
    }
    
    var event: String {
        switch self {
        case .channel:
            return "channel"
        case .dm:
            return "dm"
        }
    }
}
