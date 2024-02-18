//
//  PurchaseCompleteDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import Foundation

protocol PortOneResponseDelegate: AnyObject {
    func purchaseResponse(success: Bool, data: PortOneValidationReqDTO?, item: CoinItem?)
}
