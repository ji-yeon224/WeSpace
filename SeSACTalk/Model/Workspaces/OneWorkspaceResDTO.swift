//
//  OneWorkspaceResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import Foundation

struct OneWorkspaceResDTO: Decodable {
    
    let workspace_id: Int
    let name: String
    let description: String?
    let thumbnail: String
    let owner_id: Int
    let createdAt: String
    let channels: [ChannelResDTO]
    let workspaceMembers: [UserResDTO]
    
}
