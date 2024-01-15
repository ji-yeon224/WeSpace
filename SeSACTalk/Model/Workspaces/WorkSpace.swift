//
//  WorkSpace.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import Foundation


struct WorkSpace: Hashable {
    let id = UUID()
    let workspaceId: Int
    let name: String
    let description: String?
    let thumbnail: String
    let ownerId: Int
    let createdAt: String
    
    
}
