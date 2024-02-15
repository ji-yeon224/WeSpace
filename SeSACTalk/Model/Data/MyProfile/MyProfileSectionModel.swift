//
//  MyProfileSectionModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation
import RxDataSources

struct MyProfileSectionModel: SectionModelType {
    typealias Item = MyProfileEditItem
    
    var section: MyProfileSection
    var items: [Item]
}

extension MyProfileSectionModel {
    init(original: MyProfileSectionModel, items: [MyProfileEditItem]) {
        self = original
        self.items = items
    }
}
