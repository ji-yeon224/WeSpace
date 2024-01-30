//
//  SearchChannelDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import Foundation

protocol SearchChannelDelegate: AnyObject {
    
    func moveToChannel(channel: Channel, join: Bool)
    
}
