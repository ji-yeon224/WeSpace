//
//  RefreshResultType.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation

enum RefreshResultType{
    case success(token: String)
    case login(error: ErrorResponse)
    case error
}
