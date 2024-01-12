//
//  SearchWorkspaceManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import UIKit
import RxSwift
final class EnterViewControllerMananger {
    
    static let shared = EnterViewControllerMananger()
    
    var workspace: WorkSpace?
    let disposeBag = DisposeBag()
    private var vc: UIViewController = HomeEmptyViewController()
    private init() { }
    
    func fetchWorkspace() -> Observable<UIViewController> {
        return WorkspacesAPIManager.shared.request(api: .fetchAll, resonseType: WorkspaceResponseDTO.self)
            .asObservable()
            .map { value -> UIViewController in
                switch value {
                case .success(let data):
                    if let data = data, data.count > 0 {
                        self.workspace = data[0].toDomain()
                        return HomeTabBarController(workspace: data[0].toDomain())
                        
                    } else {
                        return HomeEmptyViewController()
                    }
                case .failure(_):
                    return OnBoardingViewController()
                }
            }
        
        
    }
    
    private func bind() {
        
    }
    
    
}
