//
//  ImageDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/4/24.
//

import Foundation
import RealmSwift

final class ImageDTO: Object {
    @Persisted(primaryKey: true) var url: String
    @Persisted(originProperty: "imgItem") var channelInfo: LinkingObjects<ChannelDTO>
    @Persisted(originProperty: "dmImg") var dmInfo: LinkingObjects<DmDTO>
    
    convenience init(url: String) {
        self.init()
        self.url = url
    }
}
