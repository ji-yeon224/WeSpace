//
//  ChatReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import ReactorKit

final class ChatReactor: Reactor {
    
//    private var channelRecord: ChannelDTO?
    
    var initialState: State = State(
        msg: "",
        loginRequest: false,
        sendSuccess: nil,
        channelRecord: nil
    )
    
    
    enum Action {
        case fetchChannel(wsId: Int, chId: Int)
        case sendRequest(channel: ChannelDTO?, id: Int?, content: String?, files: [SelectImage])
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest(login: Bool)
        case sendSuccess(data: ChannelMessage)
        case fetchChannelRecord(data: ChannelDTO)
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var sendSuccess: ChannelMessage?
        var channelRecord: ChannelDTO?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchChannel(let wsId, let chId):
            if let item = ChannelRepository().searchChannel(wsId: wsId, chId: chId).first {
                return .just(.fetchChannelRecord(data: item))
            }
            return .just(.msg(msg: "문제가 발생하였습니다."))
            
        case .sendRequest(let channel, let id, let content, let files):
            if let channel = channel, let id = id {
                let imgs = files.map {
                    return $0.img?.imageToData()
                }
                let data = ChannelChatReqDTO(content: content, files: imgs)
                return requestSendMsg(channel: channel, id: id, data: data)
            } else {
                debugPrint("[data binding error]")
                return .just(.msg(msg: "문제가 발생하였습니다."))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .msg(let msg):
            newState.msg = msg
        case .loginRequest(let login):
            newState.loginRequest = login
        case .sendSuccess(let data):
            newState.sendSuccess = data
        case .fetchChannelRecord(let data):
            newState.channelRecord = data
        }
        return newState
    }
    
    
}

extension ChatReactor {
    func requestSendMsg(channel: ChannelDTO, id: Int, data: ChannelChatReqDTO) -> Observable<Mutation> {
        if data.content == nil && data.files == nil {
            return .just(Mutation.msg(msg: "No Data"))
        }
        
        return ChannelsAPIManager.shared.request(api: .sendMsg(name: channel.name, id: id, data: data), responseType: ChannelMessageDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        print("send success")
                        let data = response.toDomain()
                        do {
                            try ChannelRepository().updateChatItems(data: channel, chat: data.toRecord())
//                            try ChannelMsgRepository().createData(data: [data.toRecord()])
                            self.saveImage(id: id, channelId: data.channelID, files: data.files, chatId: data.chatID)
                            return .just(.sendSuccess(data: data))
                        } catch {
                            print(error.localizedDescription)
                            return .just(.msg(msg: "문제가 발생하였습니다."))
                        }
                    }
                    return .just(.msg(msg: "문제가 발생하였습니다."))
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    var msg = CommonError.E99.localizedDescription
                    if let error = ChannelChatError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else if let error = CommonError(rawValue: error.errorCode) {
                        msg = error.localizedDescription
                    } else {
                        return .just(.loginRequest(login: true))
                    }
                    return .just(.msg(msg: msg))
                    
                }
                
            }
        
        
    }
    
    private func saveImage(id: Int, channelId: Int, files:[String], chatId: Int) {
        files.forEach { url in
            ImageDownloadManager.shared.getUIImage(with: url) { img in
                let fileName = ImageFileService.getFileName(type: .channel(wsId: id, channelId: channelId), fileURL: url)
                ChannelMsgRepository().saveImageToDocument(fileName: fileName, image: img)
                
            }
        }
    }
    
}

