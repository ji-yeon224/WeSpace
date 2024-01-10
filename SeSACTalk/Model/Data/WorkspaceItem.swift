//
//  WorkspaceItem.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/9/24.
//

import Foundation


struct WorkspaceItem: Hashable {
    let id = UUID()
    var title: String
    var subItems: [WorkspaceItem] // channel, dm, newfriend
    var item: Channel?
}
