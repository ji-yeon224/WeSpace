//
//  MyProfileEditItem.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/13/24.
//

import Foundation

struct MyProfileEditItem: Hashable {
    var type: MyProfileEditType
    var subText: String?
    var coin: Int?
    var email: String?
    var vendor: String?
}

enum MyProfileSection {
    case section1, section2
}
