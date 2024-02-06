//
//  SocketNetworkManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/31/24.
//

import Foundation
import SocketIO
import RxSwift


final class SocketNetworkManager {
    
    static let shared = SocketNetworkManager()
    let chatMessage = PublishSubject<ChannelMessage>()
    var isConnected: Bool = false
    private init() { }
    
    var manager: SocketManager!
    var socket:SocketIOClient!
    
    func configSocketManager(type: SocketURL) {
        
        manager = SocketManager(socketURL: type.url, config: [.log(false), .compress])
        
        socket = manager.socket(forNamespace: type.nameSpace)
        

        socket.on(clientEvent: .connect) { data, ack in
            print("SOCKET IS CONNECTED")
            self.isConnected = true
        }
        
        socket.on(type.event) {  dataArray, ack in
            
            self.decodedData(dataArray: dataArray)
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("SOCKET IS DISCONNECTED")
            self.isConnected = false
        }
    }
    
    private func decodedData(dataArray: [Any]) {
        if let data = dataArray[0] as? Dictionary<String, Any> {
            
            guard let user = data["user"] as? Dictionary<String, Any> else {
                return
            }
            let email = user["email"] as? String
            let userId = user["user_id"] as? Int
            let nickname = user["nickname"] as? String
            let profileImage = user["profileImage"] as? String
            
            if userId == UserDefaultsManager.userId {
                return 
            }
            
            let channelName = data["channelName"] as? String
            let channelId = data["channel_id"] as? Int
            let chatId = data["chat_id"] as? Int
            let content = data["content"] as? String
            let createdAt = data["createdAt"] as? String
            let files = data["files"] as? Array<String>
            
            
            
            
            guard let userId = userId, let email = email, let nickname = nickname else {
                return
            }
            
            let userData = User(userId: userId, email: email, nickname: nickname, profileImage: profileImage)

            guard let channelId = channelId, let channelName = channelName, let chatId = chatId, let createdAt = createdAt else { return }

            let chatData = ChannelMessage(channelID: channelId, channelName: channelName, chatID: chatId, content: content, createdAt: createdAt, files: files ?? [], user: userData)
            
            chatMessage.onNext(chatData)
        }
    }
    
    func connect() {
        socket.connect()
        
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
}
