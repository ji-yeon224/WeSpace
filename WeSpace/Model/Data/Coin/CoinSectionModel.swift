//
//  CoinSectionModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation
import RxDataSources

struct CoinSectionModel: SectionModelType {
    typealias Item = CoinCollectionItem
    var section: Int
    var items: [Item]
}

extension CoinSectionModel {
    init(original: CoinSectionModel, items: [CoinCollectionItem]) {
        self = original
        self.items = items
    }
}
