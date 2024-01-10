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
    
    private var channelData: [Channel] = [Channel(name: "일반")]
    private var dmData: [DM] = [DM(name: "jiyeon"), DM(name: "nailer")]
    private let newFriendDummy = [NewFriend(title: "팀원 추가")]
    
    
//    var channelSection = [WorkspaceItem(title: "", subItems: [], item: Channel(name: "일반"))]
//    var dmSection = [WorkspaceItem(title: "", subItems: [], item: DM(name: "jiyeon"))]
    
//    lazy var item = [
//        WorkspaceItem(title: "채널", subItems: channelSection, item: nil),
//        WorkspaceItem(title: "다이렉트 메세지", subItems: dmSection, item: nil),
//        WorkspaceItem(title: "팀원 추가", subItems: [], item: nil)
//    ]
    
    
    
//    lazy var menuItem: [WorkspaceItem] = {
//        return [
//            WorkspaceItem(title: "채널", subItems: [
//                WorkspaceItem(title: "", subItems: [], item: Channel(name: "일반")),
//                WorkspaceItem(title: "", subItems: [], item: Channel(name: "일반"))
//            ], item: nil),
//            WorkspaceItem(title: "다이렉트 메세지", subItems: [
//                WorkspaceItem(title: "", subItems: [], item: DM(name: "jiyeon")),
//                WorkspaceItem(title: "", subItems: [], item: DM(name: "jiyeon"))
//            ], item: nil),
//            WorkspaceItem(title: "팀원 추가", subItems: [], item: nil)
//        ]
//    }()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSnapShot()
    }
    
    
    override func configure() {
        view.backgroundColor = .white
    }
    
    private func updateSnapShot() {
//        var snapshot = NSDiffableDataSourceSnapshot<WorkspaceType, WorkspaceItem>()
//        snapshot.appendSections([.channel, .dm, .newFriend])
//        let channel = item[0]
//        let sub = item[0].subItems
        
//        snapshot.append
//        snapshot.appendItems(item[0].subItems, toSection: item[0])
//        snapshot.appendItems(channelData, toSection: .channel)
//        snapshot.appendItems(dmData, toSection: .dm)
//        snapshot.appendItems(newFriendDummy, toSection: .newFriend)
//        snapshot.appendItems(account, toSection: "계정")
//        mainView.dataSource.apply(snapshot)
        let snapshot = initialSnapshot()
//        print(snapshot.items)
        mainView.dataSource.apply(snapshot, to: .main, animatingDifferences: false)
    }
    
    func initialSnapshot() -> NSDiffableDataSourceSectionSnapshot<WorkspaceItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<WorkspaceItem>()
        
        
         var menuItem: [WorkspaceItem] = {
            return [
                WorkspaceItem(title: "채널", subItems: [
                    WorkspaceItem(title: "a", subItems: [], item: Channel(name: "일반")),
                    WorkspaceItem(title: "b", subItems: [], item: Channel(name: "일반"))
                ], item: nil)
            ]
        }()
        
        
        func addItems(_ menuItems: [WorkspaceItem], to parent: WorkspaceItem?) {
            snapshot.append(menuItems, to: parent)
            for menuItem in menuItems where !menuItem.subItems.isEmpty {
//                print(menuItem,"!!")
                addItems(menuItem.subItems, to: menuItem)
            }
        }
        
        addItems(menuItem, to: nil)
        return snapshot
    }
}
