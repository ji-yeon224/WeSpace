//
//  WorkspaceResponseDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import Foundation

struct WorkspaceDto: Decodable {
   
    let workspace_id: Int
    let name: String
    let description: String?
    let thumbnail: String
    let owner_id: Int
    let createdAt: String
    
    func toDomain() -> WorkSpace {
        return WorkSpace(workspaceId: workspace_id, name: name, description: description, thumbnail: thumbnail, ownerId: owner_id, createdAt: createdAt)
    }
   
    
}
typealias WorkspaceResponseDTO = [WorkspaceDto]


