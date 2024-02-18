//
//  ChannelSectionModel.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import Foundation
import RxDataSources

struct ChannelSectionModel: SectionModelType {
    typealias Item = Channel
    
    var section: String
    var items: [Item]
    
    
}

extension ChannelSectionModel {
    init(original: ChannelSectionModel, items: [Channel]) {
        self = original
        self.items = items
    }
}
