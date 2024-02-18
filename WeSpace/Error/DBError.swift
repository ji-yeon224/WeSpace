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
    case updateError
    case deleteError
    case searchError
}

extension DBError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .createError:
            return "[DB CREATE ERROR]"
        case .fetchError:
            return "[DB FETCH ERROR]"
        case .updateError:
            return "[DB UPDATE ERROR]"
        case .deleteError:
            return "[DB DELETE ERROR]"
        case .searchError:
            return "[DB SEARCH ERROR]"
        }
    }
}
