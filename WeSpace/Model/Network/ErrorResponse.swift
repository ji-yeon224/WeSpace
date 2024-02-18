//
//  ErrorResponse.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/4/24.
//

import Foundation

struct ErrorResponse: Decodable, Error {
    let errorCode: String
}
