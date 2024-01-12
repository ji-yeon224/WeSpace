//
//  HomeViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit
import ReactorKit

final class HomeViewController: BaseViewController, View {
    
    private let mainView = HomeView()
    var disposeBag = DisposeBag()
    private let requestWSInfo = PublishSubject<Bool>()
    private let requestDMsInfo = PublishSubject<Bool>()
    
    private var workspace: WorkSpace?
    
    override func loadView() {
        self.view = mainView
    }
    
    init(workspace: WorkSpace) {
        super.init(nibName: nil, bundle: nil)
        self.workspace = workspace
        print(workspace)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = HomeReactor()
        requestWSInfo.onNext(true)
        requestDMsInfo.onNext(true)
        
    }
    
    override func configure() {
        view.backgroundColor = .white
        sectionSnapShot()
        let newFriend = [ WorkspaceItem(title: "", subItems: [], item: NewFriend(title: "팀원 추가")) ]
        updateSnapShot(section: .newFriend, item: newFriend)
    }
    
    
}

extension HomeViewController {
    func bind(reactor: HomeReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: HomeReactor) {
        
        guard let workspace = workspace else { return }
        
        requestWSInfo
            .map{ _ in Reactor.Action.requestInfo(id: workspace.workspaceId)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestDMsInfo
            .map { _ in Reactor.Action.requestDMsInfo(id: workspace.workspaceId)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: HomeReactor) {
        reactor.state
            .map { $0.channelItems }
            .filter{
                !$0.isEmpty
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                let channelSection = WorkspaceItem(title: "채널", subItems: value)
                owner.updateSnapShot(section: .channel, item: [channelSection])
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dmRoomItems }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                let dmSection = WorkspaceItem(title: "다이렉트 메세지", subItems: value)
                owner.updateSnapShot(section: .dm, item: [dmSection])
                
            }
            .disposed(by: disposeBag)
    }
    
}

extension HomeViewController {
    private func sectionSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<WorkspaceType, WorkspaceItem>()
        snapshot.appendSections([.channel, .dm, .newFriend])
        mainView.dataSource.apply(snapshot)
        
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
        
        snapshot.append(items, to: nil)
        for item in items where !item.subItems.isEmpty{
            snapshot.append(item.subItems, to: item)
            if !item.subItems.isEmpty {
                snapshot.expand(items)
            }
        }
       
        return snapshot
    }
}
