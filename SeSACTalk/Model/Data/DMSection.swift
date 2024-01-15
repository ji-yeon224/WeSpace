//
//  DM.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/9/24.
//

import Foundation

struct DMSection: Hashable, Identifiable {
    let id = UUID()
    let section: String
    let items: [DMsRoom]
}
