//
//  HomeViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit
import ReactorKit
import SideMenu

final class HomeViewController: BaseViewController, View {
    
    
    private let mainView = HomeView()
    var disposeBag = DisposeBag()
    private let requestWSInfo = PublishSubject<Bool>()
    private let requestDMsInfo = PublishSubject<Bool>()
    private let requestAllWorkspaceInfo = PublishSubject<Bool>()
    
    private var workspace: WorkSpace?
    private var allWorkspace: [WorkSpace]?
    
    override func loadView() {
        self.view = mainView
    }
    
    init(workspace: WorkSpace) {
        super.init(nibName: nil, bundle: nil)
        self.workspace = workspace

    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.reactor = HomeReactor()
        initData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    override func configure() {
        view.backgroundColor = .white
        sectionSnapShot()
        let newFriend = [ WorkspaceItem(title: "", subItems: [], item: NewFriend(title: "팀원 추가")) ]
        updateSnapShot(section: .newFriend, item: newFriend)
        SideMenuVCManager.shared.initSideMenu(vc: self, curWS: workspace)

    }
    
    private func initData() {
        requestWSInfo.onNext(true)
        requestDMsInfo.onNext(true)
        requestAllWorkspaceInfo.onNext(true)
        
    }
    
}



extension HomeViewController {
    func bind(reactor: HomeReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: HomeReactor) {
        
        requestWSInfo
            .map{ _ in
                Reactor.Action.requestInfo(id: self.workspace?.workspaceId)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestDMsInfo
            .map { _ in Reactor.Action.requestDMsInfo(id: self.workspace?.workspaceId)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        requestAllWorkspaceInfo
            .map { _ in Reactor.Action.requestAllWorkspace }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        
    }
    
    
    private func bindState(reactor: HomeReactor) {
        reactor.state
            .map { $0.channelItem }
            .filter{
                !$0.isEmpty
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                var sub = value
                sub.append(WorkspaceItem(title: "", subItems: [], plus: "채널 추가"))
                let channelSection = WorkspaceItem(title: "채널", subItems: sub)
                owner.updateSnapShot(section: .channel, item: [channelSection])
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dmRoomItems }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                var sub = value
                sub.append(WorkspaceItem(title: "", subItems: [], plus: "새 메세지 시작"))
                let dmSection = WorkspaceItem(title: "다이렉트 메세지", subItems: sub)
                owner.updateSnapShot(section: .dm, item: [dmSection])
                
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.allWorkspace }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.allWorkspace = value
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.workspaceItem }
            .filter {
                $0 != .none
            }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if let value = value {
                    
                    owner.configData(ws: value)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    private func bindEvent() {
        mainView.topView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                SideMenuVCManager.shared.presentSideMenu()
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.isSideVCAppear)
            .bind(with: self) { owner, noti in
                if let show = noti.userInfo?[UserInfo.alphaShow] as? Bool {
                    owner.mainView.alphaView.isHidden = !show
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.refreshWS)
            .bind(with: self) { owner, _ in
                owner.requestWSInfo.onNext(true)
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.resetWS)
            .bind(with: self) { owner, noti in
                if let ws = noti.userInfo?[UserInfo.workspace] as? WorkSpace {
                    owner.workspace = ws
                    SideMenuVCManager.shared.setWorkspaceData(ws: ws)
                    owner.initData()
                }
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexPath in
//                if owner.mainView.collectionView.cellForItem(at: indexPath) as?
                owner.itemSelected(indexPath: indexPath)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func itemSelected(indexPath: IndexPath) {
        let item = mainView.dataSource.itemIdentifier(for: indexPath)
        
        guard let item = item else { return }
        
        if let channelItem = item.item as? Channel {
            print(channelItem.name)
        } else if let dmItem = item.item as? DMsRoom {
            print(dmItem.user)
        } else if let invite = item.item as? NewFriend {
            print("팀원 추가")
        } else if let plus = item.plus {
            print(plus)
        }
        
        
    }
    
    private func configData(ws: WorkSpace) {
        mainView.topView.wsImageView.setImage(with: ws.thumbnail)
        mainView.topView.workSpaceName.text = ws.name
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
            if item.subItems.count > 1 {
                snapshot.expand(items)
            }
        }
       
        return snapshot
    }
}

