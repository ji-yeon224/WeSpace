//
//  PushNotiCoordinator.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/17/24.
//

import UIKit
import RxSwift


final class PushNotiCoordinator {
    
    static let shared = PushNotiCoordinator()
    private init() { }
    private let disposeBag = DisposeBag()
    var window: UIWindow?
    var channelData: (Int, String)? // wsid, wsname
    var dmData: (Int, Int, Int)? //wsid, roomid, userid
    
    func configPushNotiTabAction(responseInfo: Data) {
        if let pushData = responseInfo.convertToPushDto, let wsId = Int(pushData.workspaceID) {
            print(pushData)
            fetchWorkspace(wsId: wsId)
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let response):
                        if let response = response {
                            
                            if pushData.type == "channel" {
                                let name = pushData.aps.alert.body.components(separatedBy: "\n")[0].splitHashtag
                                
                                owner.channelData = (wsId, name)
                            } else {
                                if let roomIdStr = pushData.roomID, let userIdStr = pushData.oppendID, let roomId = Int(roomIdStr), let userId = Int(userIdStr) {
                                    owner.dmData = (wsId, roomId, userId)
                                }
                            }
                            owner.window?.rootViewController = HomeTabBarController(workspace: response, type: pushData.type)
                            owner.window?.makeKeyAndVisible()
                        }
                    case .failure(let error):
                        debugPrint(error.errorCode)
                        owner.window?.rootViewController = OnBoardingViewController()
                        owner.window?.makeKeyAndVisible()
                    }
                }
                .disposed(by: disposeBag)
        }
        
    }
    
    private func fetchWorkspace(wsId: Int) -> Observable<Result<WorkSpace?, ErrorResponse>> {
        
        return Observable.create { result in
            
            WorkspacesAPIManager.shared.request(api: .fetchOne(id: wsId), resonseType: WorkspaceDto.self)
                .asObservable()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(let response):
                        if let response = response {
                            result.onNext(.success(response.toDomain()))
                            result.onCompleted()
                        } else {
                            result.onNext(.success(nil))
                            result.onCompleted()
                        }
                    case .failure(let error):
                        result.onNext(.failure(error))
                        result.onCompleted()
                        
                    }
                }
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    
    
}

