//
//  DBError.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation

enum DBError: String, Error {
    case createError
    case fetchError
}

extension DBError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .createError:
            return "[DB CREATE ERROR]"
        case .fetchError:
            return "[DB FETCH ERROR]"
        }
    }
}
