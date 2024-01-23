//
//  SelectImageModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/23/24.
//

import UIKit
import RxDataSources

struct SelectImageModel: SectionModelType {
    typealias Item = SelectImage
    var section: String
    var items: [SelectImage]
}

extension SelectImageModel {
    init(original: SelectImageModel, items: [SelectImage]) {
        self = original
        self.items = items
    }
}
