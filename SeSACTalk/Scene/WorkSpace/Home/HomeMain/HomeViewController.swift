//
//  HomeViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit
import ReactorKit
import RxCocoa
import SideMenu

final class HomeViewController: BaseViewController, View {
    
    
    private let mainView = HomeView()
    var disposeBag = DisposeBag()
    private let requestChannelInfo = PublishSubject<Bool>()
    private let requestDMsInfo = PublishSubject<Bool>()
    private let requestAllWorkspaceInfo = PublishSubject<Bool>()
    
    private let createChannel = PublishRelay<Void>()
    private let searchChannel = PublishRelay<Void>()
    
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
        requestChannelInfo.onNext(true)
        requestDMsInfo.onNext(true)
        requestAllWorkspaceInfo.onNext(true)
        if let workspace = workspace {
            configData(ws: workspace)
        }
        
    }
    
    private func configData(ws: WorkSpace) {
        mainView.topView.wsImageView.setImage(with: ws.thumbnail)
        mainView.topView.workSpaceName.text = ws.name
    }
    
}


// ReactorKit
extension HomeViewController {
    func bind(reactor: HomeReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
        homeItemEvent()
    }
    
    private func bindAction(reactor: HomeReactor) {
        
        requestChannelInfo
            .map{ _ in
                Reactor.Action.requestChannelInfo(id: self.workspace?.workspaceId)
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
                owner.requestChannelInfo.onNext(true)
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
                owner.itemSelected(indexPath: indexPath)
            }
            .disposed(by: disposeBag)
                
    }
    
    
    
}

// collectionview select
extension HomeViewController {
    private func homeItemEvent() {
        
        createChannel
            .bind(with: self) { owner, _ in
                let vc = CreateChannelViewController(workspace: owner.workspace)
                vc.createComplete = {
                    owner.showToastMessage(message: ChannelToastMessage.successCreate.message, position: .bottom)
                    owner.requestChannelInfo.onNext(true)
                    
                }
                owner.presentPageSheet(vc: vc)
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
        } else if let _ = item.item as? NewFriend {
            if UserDefaultsManager.userId == workspace?.ownerId {
                let vc = InviteViewController()
                vc.workspace = workspace
                vc.complete = {
                    self.showToastMessage(message: WorkspaceToastMessage.successInvite.message, position: .bottom)
                }
                presentPageSheet(vc: vc)
            } else { // 관리자 아님
                self.showToastMessage(message: WorkspaceToastMessage.invalidInvite.message, position: .bottom)
            }
            
        } else if let plus = item.plus {
            if indexPath.section == 0 {
                present(showChannelActionSheet(), animated: true)
            }
            print(plus)
        }
        
        
    }
    
    private func presentPageSheet(vc: UIViewController) {
        let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
        nav.setupBarAppearance()
        present(nav, animated: true)
    }
    
    private func showChannelActionSheet() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let create = UIAlertAction(title: "채널 생성", style: .default) { _ in
            self.createChannel.accept(())
        }
        let search = UIAlertAction(title: "채널 탐색", style: .default) { _ in
            self.searchChannel.accept(())
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        [create, search, cancel].forEach {
            actionSheet.addAction($0)
        }
        
        return actionSheet
    }
    
}


// snapshot
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

