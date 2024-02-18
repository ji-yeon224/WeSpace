//
//  CoinPurchageDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation

protocol CoinPurchaseDelegate: AnyObject {
    func purchaseCoin(item: CoinItem)
}
