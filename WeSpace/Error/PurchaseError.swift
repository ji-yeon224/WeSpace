//
//  PurchaseError.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import Foundation

enum PurchaseError: String, Error {
    case E81, E82
}

extension PurchaseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .E81:
            return "이미 결제가 완료된 내역입니다."
        case .E82:
            return "유효하지 않은 결제 내역입니다."
        }
    }
}
