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
    private let requestChannelInfo = PublishSubject<Void>()
    private let requestDMsInfo = PublishSubject<Void>()
    private let requestAllWorkspaceInfo = PublishSubject<Bool>()
    private let requestChatItems = PublishRelay<Void>()
    private let createChannel = PublishRelay<Void>()
    private let searchChannel = PublishRelay<Void>()
    private let enterChannel = PublishRelay<Channel>()
    private let requestMyInfo = PublishRelay<Void>()
    private let requestPushAction = PublishRelay<(Int, String)>()
    
    private let enterDmRoom = PublishRelay<DMsRoom>()
    private let dmRoomData = PublishRelay<(DmDTO?, [DmChat])>()
    private let dmUserData = PublishRelay<User>()
    
    private let channelChatInfo = PublishRelay<(ChannelDTO?, [ChannelMessage])>()
    private let channelChatUserInfo = PublishRelay<[Int: User]>()
    
    private var workspace: WorkSpace?
    private var allWorkspace: [WorkSpace]?
    private var isNeedChannelRefresh: Bool = false
    private var myInfo: User?
    
    private var isPush: Bool = false
    override func loadView() {
        self.view = mainView
    }
    
    init(workspace: WorkSpace, push: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.workspace = workspace
        self.isPush = push
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        SideMenuVCManager.shared.setViewController(vc: self, ws: workspace)
        SideMenuVCManager.shared.enableSideMenu()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestChannelInfo.onNext(())
        requestDMsInfo.onNext(())
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SideMenuVCManager.shared.disableSideMenu()
    }
    override func configure() {
        self.reactor = HomeReactor()
        view.backgroundColor = .white
        sectionSnapShot()
        requestMyInfo.accept(())
        let newFriend = [ WorkspaceItem(title: "", subItems: [], item: NewFriend(title: "팀원 추가")) ]
        updateSnapShot(section: .newFriend, item: newFriend)
//        SideMenuVCManager.shared.initSideMenu(vc: self, curWS: workspace)
        
        if !DeviceTokenManager.shared.saveTokenSuccess {
            DeviceTokenManager.shared.requestSaveDeviceToken(token: UserDefaultsManager.deviceToken)
        }

        if isPush {
            if let data = PushNotiCoordinator.shared.channelData {
                requestPushAction.accept(data)
                isPush = false
            }
            
        }
        
    }
    
    private func initData() {
        
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
        notificationEvent()
    }
    
    private func bindAction(reactor: HomeReactor) {
        
        requestChannelInfo
            .throttle(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.requestChannelInfo(id: self.workspace?.workspaceId) }
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
        
        enterChannel
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.searchChannelDB(wsId: self.workspace?.workspaceId, chInfo: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestMyInfo
            .map { Reactor.Action.requestMyInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        enterDmRoom
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.requestDmRoomInfo(wsId: $0.workspaceID, roomId: $0.roomID, userId: $0.user.userId)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestPushAction
            .map {
                Reactor.Action.requestOneChannelInfo(wsId: $0.0, name: $0.1)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    
    private func bindState(reactor: HomeReactor) {
        
        reactor.state
            .map { $0.message }
            .filter { $0.count != 0 }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)
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
        
        reactor.state
            .map { $0.chatInfo }
            .filter {
                return $0.0 != .none
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.channelChatInfo.accept(value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userInfo }
            .asDriver(onErrorJustReturn: [:])
            .filter { return !$0.isEmpty }
            .drive(with: self) { owner, value in
                owner.channelChatUserInfo.accept(value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.myInfo }
            .filter { $0 != .none }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                owner.myInfo = value
                
                if let value = value, let profile = value.profileImage {
                    
                    owner.mainView.topView.profileImageView.setImage(with: profile)
                } else {
                    owner.mainView.topView.profileImageView.image = Constants.Image.dummyProfile[UserDefaultsManager.userId % 3]
                }
                
                
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dmInfo }
            .filter { $0.0 != .none }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.dmRoomData.accept(value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dmUserInfo }
            .filter { $0 != .none }
            .asDriver(onErrorJustReturn: nil)
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                if let value = value {
                    owner.dmUserData.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.oneChannel }
            .filter { $0 != .none }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let value = value {
                    owner.enterChannel.accept(value)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    
    private func bindEvent() {
        
        dmRoomData
            .withLatestFrom(dmUserData) { dmInfo, userInfo in
                return (dmInfo, userInfo)
            }
            .bind(with: self) { owner, value in
                let dmDto = value.0.0
                let chat = value.0.1
                let user = value.1
                if let myInfo = owner.myInfo {
                    let userInfo = [myInfo.userId: myInfo, user.userId: user]
                    let vc = DmChatViewController(dmInfo: dmDto, dmChatItem: chat, userInfo: userInfo)
                    vc.hidesBottomBarWhenPushed = true
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        channelChatInfo
            .withLatestFrom(channelChatUserInfo) { chatInfo, userInfo in
                return (chatInfo, userInfo)
            }
            .bind(with: self) { owner, value in
                let channelDto = value.0.0
                let chatMsg = value.0.1
                let userInfo = value.1
                if let ws = owner.workspace, let channel = channelDto {
                    let vc = ChatViewController(info: channel, workspace: ws, chatItems: chatMsg, userInfo: userInfo)
                    vc.delegate = self
                    vc.hidesBottomBarWhenPushed = true
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        
        mainView.topView.workSpaceName.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                SideMenuVCManager.shared.presentSideMenu()
            }
            .disposed(by: disposeBag)
        
        mainView.topView.wsImageView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                SideMenuVCManager.shared.presentSideMenu()
            }
            .disposed(by: disposeBag)
        
        mainView.topView.profileImageView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                let vc = MyProfileViewController()
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexPath in
                owner.itemSelected(indexPath: indexPath)
            }
            .disposed(by: disposeBag)
        
        searchChannel
            .bind(with: self) { owner, _ in
                if let workspace = owner.workspace {
                    let vc = SearchChannelViewController(workspace: workspace)
                    vc.delegate = self
                    vc.hidesBottomBarWhenPushed = true
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
               
            }
            .disposed(by: disposeBag)
                
    }
    
    private func notificationEvent() {
        NotificationCenter.default.rx.notification(.isSideVCAppear)
            .bind(with: self) { owner, noti in
                if let show = noti.userInfo?[UserInfo.alphaShow] as? Bool {
                    owner.mainView.alphaView.isHidden = !show
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.refreshWS)
            .bind(with: self) { owner, _ in
                owner.requestChannelInfo.onNext(())
            }
            .disposed(by: disposeBag)
        
        
        NotificationCenter.default.rx.notification(.refreshChannel)
            .bind(with: self) { owner, _ in
                owner.requestChannelInfo.onNext(())
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.refreshProfile)
            .bind(with: self) { owner, noti in
                if let img = noti.userInfo?[UserInfo.imageUrl] as? String {
                    if !img.isEmpty {
                        owner.mainView.topView.profileImageView.setImage(with: img)
                    }
                }
            }
            .disposed(by: disposeBag)
        
    }
    private func reloadHomeView(ws: WorkSpace) {
        let vc = HomeTabBarController(workspace: ws)
        view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()
    }
    
    
}
extension HomeViewController: ChannelChatDelegate {
    func refreshChannelList(data: [Channel]) {
        var channelItems = data.map { return WorkspaceItem(title: "", subItems: [], item: $0)}
        
        channelItems.append(WorkspaceItem(title: "", subItems: [], plus: "채널 추가"))
        let channelSection = WorkspaceItem(title: "채널", subItems: channelItems)
        updateSnapShot(section: .channel, item: [channelSection])
    }
}
extension HomeViewController: SearchChannelDelegate {
    func moveToChannel(channel: Channel, join: Bool) {
        
        if !join {
            enterChannel.accept(channel)
        }
        
        isNeedChannelRefresh = join
        print(isNeedChannelRefresh)
    }
}

// collectionview select
extension HomeViewController {
    private func homeItemEvent() {
        
        createChannel
            .bind(with: self) { owner, _ in
                if let workspace = owner.workspace {
                    let vc = CreateChannelViewController(wsId: workspace.workspaceId)
                    vc.createComplete = {
                        owner.showToastMessage(message: ChannelToastMessage.successCreate.message, position: .bottom)
                        owner.requestChannelInfo.onNext(())
                        
                    }
                    owner.presentPageSheet(vc: vc)
                }
                
            }
            .disposed(by: disposeBag)
        
    }
    
    private func itemSelected(indexPath: IndexPath) {
        let item = mainView.dataSource.itemIdentifier(for: indexPath)
        
        guard let item = item else { return }
        
        if let channelItem = item.item as? Channel {
            enterChannel.accept(channelItem)
        } else if let dmItem = item.item as? DMsRoom {
            enterDmRoom.accept(dmItem)
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
            
        } else if let _ = item.plus {
            if indexPath.section == 0 {
                present(showChannelActionSheet(), animated: true)
            }
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

    private func initialSnapshot(items: [WorkspaceItem]) -> NSDiffableDataSourceSectionSnapshot<WorkspaceItem> {
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

