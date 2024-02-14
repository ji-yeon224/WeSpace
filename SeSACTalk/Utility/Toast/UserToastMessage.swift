//
//  UserToastMessage.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import Foundation

enum UserToastMessage {
    case loadFail
    case otherError
    case changeProfileImage
    case updateNickname
    case updatePhone
}

extension UserToastMessage {
    var message: String {
        switch self {
        case .loadFail:
            return "정보를 불러오는데 실패하였습니다."
        case .otherError:
            return "문제가 발생하였습니다."
        case .changeProfileImage:
            return "프로필 이미지가 성공적으로 변경되었습니다."
        case .updatePhone:
            return "전화번호를 변경하였습니다."
        case .updateNickname:
            return "닉네임을 변경하였습니다."
        }
    }
}
