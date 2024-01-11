//
//  Item.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/9/24.
//

import Foundation
struct Item: Hashable {
    var title: String
    var subItems: [AnyHashable]
}
