//
//  WorkspaceType.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/9/24.
//

import Foundation

enum WorkspaceType {
    case channel
    case dm
    case newFriend
}


struct NewFriend: Hashable {
    let title: String
}


