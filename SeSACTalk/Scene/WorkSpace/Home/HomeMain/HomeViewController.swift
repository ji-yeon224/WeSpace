//
//  HomeViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit
import ReactorKit

final class HomeViewController: BaseViewController {
    
    private let mainView = HomeView()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // vm [ channelItem ] -> channelSection 담기 -> snapshot .channel
        let channelItem = [
            WorkspaceItem(title: "a", subItems: [], item: Channel(name: "일반")),
            WorkspaceItem(title: "b", subItems: [], item: Channel(name: "일반"))
        ]
        let dmItem = [
            WorkspaceItem(title: "", subItems: [], item: DM(name: "jiyeon12")),
            WorkspaceItem(title: "", subItems: [], item: DM(name: "jiyeon23"))
        ]
        let newFriend = [
            WorkspaceItem(title: "", subItems: [], item: NewFriend(title: "팀원 추가"))
        ]
        
        let channelSection = WorkspaceItem(title: "채널", subItems: channelItem)
        let dmSection = WorkspaceItem(title: "다이렉트 메세지", subItems: dmItem)
        
        
        updateSnapShot(section: .channel, item: [channelSection])
        updateSnapShot(section: .dm, item: [dmSection])
        updateSnapShot(section: .newFriend, item: newFriend)
    }
    
    
    override func configure() {
        view.backgroundColor = .white
    }
    
    private func updateSnapShot(section: WorkspaceType, item: [WorkspaceItem]) {
        let snapshot = initialSnapshot(items: item)
        
        switch section {
        case .channel:
            mainView.dataSource.apply(snapshot, to: .channel, animatingDifferences: false)
        case .dm:
            mainView.dataSource.apply(snapshot, to: .dm, animatingDifferences: false)
        case .newFriend:
            mainView.dataSource.apply(snapshot, to: .newFriend, animatingDifferences: false)
        }
        
        
    }
    
    
    func initialSnapshot(items: [WorkspaceItem]) -> NSDiffableDataSourceSectionSnapshot<WorkspaceItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<WorkspaceItem>()
        
        func addItems(_ menuItems: [WorkspaceItem], to parent: WorkspaceItem?) {
            snapshot.append(menuItems, to: parent)
            for menuItem in menuItems where !menuItem.subItems.isEmpty {
                addItems(menuItem.subItems, to: menuItem)
            }
        }
        
        addItems(items, to: nil)
        return snapshot
    }
}
