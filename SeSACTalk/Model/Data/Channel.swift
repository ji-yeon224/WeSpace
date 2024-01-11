//
//  Channel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/9/24.
//

import Foundation

struct ChannelSection: Hashable, Identifiable {
    let id = UUID()
    var section: String
    let items: [Channel]
}

struct Channel: Hashable {
    let name: String
}

/*
 "workspace_id": "1",
   "channel_id": 1,
   "name": "일반",
   "description": "이 채널은 일반채널입니다.",
   "owner_id": 5,
   "private": 0,
   "createdAt": "2023-12-21T22:47:30.236Z"
 */
