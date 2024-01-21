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
    case editWorkspace
    case invalidEmail
    case successInvite
    case invalidInvite
}

extension WorkspaceToastMessage {
    var message: String {
        switch self {
        case .makeNameInvalid:
            return "워크스페이스 이름은 1~30자로 설정해주세요. "
        case .makeNoImage:
            return "워크스페이스 이미지를 등록해주세요. "
        case .editWorkspace:
            return "워크스페이스가 편집되었습니다."
        case .invalidEmail:
            return "올바른 이메일을 입력해주세요."
        case .successInvite:
            return "멤버를 성공적으로 초대했습니다."
        case .invalidInvite:
            return "워크스페이스 관리자만 팀원을 초대할 수 있어요. \n관리자에게 요청을 해보세요."
        }
    }
}
