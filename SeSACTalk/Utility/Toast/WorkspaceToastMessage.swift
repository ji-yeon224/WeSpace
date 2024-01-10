//
//  WorkspaceCreateToast.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/11/24.
//

import Foundation

enum WorkspaceToastMessage {
    case makeNameInvalid
    case makeNoImage
}

extension WorkspaceToastMessage {
    var message: String {
        switch self {
        case .makeNameInvalid:
            return "워크스페이스 이름은 1~30자로 설정해주세요. "
        case .makeNoImage:
            return "워크스페이스 이미지를 등록해주세요. "
        }
    }
}
