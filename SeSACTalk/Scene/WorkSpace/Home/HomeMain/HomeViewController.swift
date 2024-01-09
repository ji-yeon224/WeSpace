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
    private var dmData: [DM] = [DM(name: "jiyeon")]
    private let newFriendDummy = [NewFriend(title: "팀원 추가")]
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.reactor = HomeReactor()
        updateSnapShot()
    }
//    
//    func bind(reactor: HomeReactor) {
//        bindAction(reactor: reactor)
//        bindState(reactor: reactor)
//    }
//    
//    private func bindAction(reactor: HomeReactor) {
//        
//    }
//    
//    private func bindState(reactor: HomeReactor) {
//        
//    }
    
    
    override func configure() {
        view.backgroundColor = .white
    }
    
    private func updateSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<WorkspaceType, AnyHashable>()
        snapshot.appendSections([.channel, .dm, .newFriend])
        
        snapshot.appendItems(channelData, toSection: .channel)
        snapshot.appendItems(dmData, toSection: .dm)
        snapshot.appendItems(newFriendDummy, toSection: .newFriend)
//        snapshot.appendItems(account, toSection: "계정")
        mainView.dataSource.apply(snapshot)
    }
}
