//
//  File.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import Foundation
 
struct BillingResultResDTO: Decodable {
    let billing_id: Int
    let merchant_uid: String
    let amount: Int
    let sesacCoin: Int
    let success: Bool
    let createdAt: String

    
}

