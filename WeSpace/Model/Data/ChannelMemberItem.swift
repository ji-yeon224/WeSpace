//
//  ChannelMemberSection.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import Foundation

struct ChannelMemberItem: Hashable {
    let id = UUID()
    var title: String
    var subItems: [ChannelMemberItem]
    var item: User?
}

