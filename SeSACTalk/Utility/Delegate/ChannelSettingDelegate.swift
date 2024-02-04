//
//  ChannelSettingDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/5/24.
//

import Foundation

protocol ChannelSettingDelegate: AnyObject {
    func channelExitRefresh(data: [Channel])
}
