//
//  PurchaseToastMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import Foundation

enum PurchaseToastMessage {
    case fail
    case success(coin: String)
}
extension PurchaseToastMessage {
    var message: String {
        switch self {
        case .fail:
            return "결제에 실패하였습니다."
        case .success(let coin):
            return "\(coin) Coin이 결제되었습니다."
        }
    }
}
