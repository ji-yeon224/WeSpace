//
//  ChatReactor.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//

import Foundation
import ReactorKit

final class ChatReactor: Reactor {
    var initialState: State = State(
        msg: "",
        loginRequest: false,
        sendSuccess: nil
    )
    
    
    enum Action {
        case sendRequest(name: String?, id: Int?, content: String?, files: [SelectImage])
    }
    
    enum Mutation {
        case msg(msg: String)
        case loginRequest(login: Bool)
        case sendSuccess(data: ChannelMessage)
    }
    
    struct State {
        var msg: String
        var loginRequest: Bool
        var sendSuccess: ChannelMessage?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sendRequest(let name, let id, let content, let files):
            if let name = name, let id = id {
                let imgs = files.map {
                    return $0.img?.imageToData()
                }
                let data = ChannelChatReqDTO(content: content, files: imgs)
                return requestSendMsg(name: name, id: id, data: data)
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
        }
        return newState
    }
    
    
}

extension ChatReactor {
    func requestSendMsg(name: String, id: Int, data: ChannelChatReqDTO) -> Observable<Mutation> {
        if data.content == nil && data.files == nil {
            return .just(Mutation.msg(msg: "No Data"))
        }
        
        return ChannelsAPIManager.shared.request(api: .sendMsg(name: name, id: id, data: data), responseType: ChannelMessageDTO.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let response):
                    if let response = response {
                        print("send success")
                        let data = response.toDomain()
                        do {
                            try ChannelMsgRepository().createData(data: [data.toRecord()])
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

