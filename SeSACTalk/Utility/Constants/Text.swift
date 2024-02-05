//
//  Text.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import Foundation

enum Text {
    static let completMessage = "님의 조직을 위해 새로운 새싹톡 워크스페이스를 시작할 준비가 완료되었어요!"
    static let makeWorkspace = "워크스페이스 생성"
    
    static let noWorkSpaceTitle = "워크스페이스를 찾을 수 없어요."
    static let noWorkSpaceTitle_small = "워크스페이스를\n 찾을 수 없어요."
    static let noWorkSpace = "관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나 새로운 워크스페이스를 생성해주세요."
    static let noWorkSpace_small = "관리자에게 초대를 요청하거나,\n다른 이메일로 시도하거나\n 새로운 워크스페이스를 생성해주세요."
    
    static let makeSpaceNamePH = "워크스페이스 이름을 입력하세요(필수)"
    static let makeSpaceDescPH = "워크스페이스를 설명하세요(옵션)"
    
    
    // WorkspaceListViewController
    static let wsExitTitle = "워크스페이스 나가기"
    static let workspaceExitManager = "회원님은 워크스페이스 관리자입니다. 워크스페이스 관리자를 다른 멤버로 변경한 후 나갈 수 있습니다."
    static let workspaceExit = "정말 이 워크스페이스를 떠나시겠습니까?"
    
    static let wsDeleteTitle = "워크스페이스 삭제"
    static let workspaceDelete = "정말 이 워크스페이스를 삭제하시겠습니까? 삭제 시 채널/멤버/채팅 등 워크스페이스 내의 모든 정보가 삭제되며 복구할 수 없습니다."
    
    // ChangeMemberViewController
    static let noMemberTitle = "워크스페이스 관리자 변경 불가"
    static let noMemberMessage = "워크스페이스 멤버가 없어 관리자 변경을 할 수 없습니다.\n 새로운 멤버를 워크스페이스에 초대해보세요."
    
    static let changeManagerTitle = "{name} 님을 관리자로 지정하시겠습니까?"
    static let changeManagerMessage = """
    워크스페이스 관리자는 다음과 같은 권한이 있습니다. \n
    ・ 워크스페이스 이름 또는 설명 변경
    ・ 워크스페이스 삭제
    ・ 워크스페이스 멤버 초대
    """
    
    // InviteView
    static let inviteEmailPlaceholder = "초대하려는 팀원의 이메일을 입력하세요."
    
    // CreateChannel
    static let createChannelNamePlaceholder = "채널 이름을 입력하세요.(필수)"
    static let createChannelDescrptionPlaceholder = "채널을 설명하세요.(옵션)"
    
    // SearchChannel
    static let joinTitle = "채널 참여"
    static let joinChannel = "[{channel}] 채널에 참여하시겠습니까?"
    
    // ChannelSettingView
    static let editChannelTitle = "채널 편집"
    static let exitChannelTitle = "채널에서 나가기"
    static let changeChannelTitle = "채널 관리자 변경"
    static let deleteChannelTitle = "채널 삭제"
    
    static let exitChannelManagerMessage = "회원님은 채널 관리자입니다. 채널 관리자를 다른 멤버로 변경한 후 나갈 수 있습니다."
    static let exitChannelMessage = "나가기를 하면 채널 목록에서 삭제됩니다."
    
    static let cannotChangeTitle = "채널 관리자 변경"
    static let cannotChangeMsg = "채널 멤버가 없어 관리자를 변경할 수 없습니다."
    static let changeCHManagerTitle = "{name} 님을 관리자로 지정하시겠습니까?"
    static let changeCHManagerMessage = """
    채널 관리자는 다음과 같은 권한이 있습니다. \n
    ・ 채널 이름 또는 설명 변경
    ・ 채널 삭제
    """
}
