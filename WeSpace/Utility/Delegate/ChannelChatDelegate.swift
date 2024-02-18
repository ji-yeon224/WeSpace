//
//  ChannelChatDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/5/24.
//

import Foundation

protocol ChannelChatDelegate: AnyObject {
    func refreshChannelList(data: [Channel]) 
}
