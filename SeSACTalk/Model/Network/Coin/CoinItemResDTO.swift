//
//  CoinItemResDTO.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/15/24.
//

import Foundation

struct CoinItemResDTO: Decodable {
    let item: String
    let amount: String
    
    func toDomain() -> CoinItem {
        return .init(item: item, amount: amount)
    }
}

typealias CoinItemListRes = [CoinItemResDTO]
