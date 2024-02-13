//
//  DMListViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class DMListViewController: BaseViewController {
    
    private var workspace: WorkSpace?
    private var mainView = DMListView()
    var disposeBag = DisposeBag()
    
    private var member: [DmItems] = []
    private var chatData: [DmItems] = []
    private var requestMemberList = PublishRelay<Int?>()
    private var requestDmList = PublishRelay<Int?>()
    private var enterDmRoom = PublishRelay<DMsRoom>()
    private var requestUserInfo = PublishRelay<Int>()
    private let requestMyInfo = PublishRelay<Void>()
    
    private let enterDmData = PublishRelay<(DmDTO?, [DmChat])>()
    private let dmUserData = PublishRelay<User>()
    private let selectUserCell = PublishRelay<User>()
    
    private var myInfo: User?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let workspace = workspace else { return }
//        requestMemberList.accept(workspace.workspaceId)
        requestDmList.accept(workspace.workspaceId)
    }
    
    override func configure() {
//        super.configure()
        guard let workspace = workspace else { return }
        configData(ws: workspace)
        self.reactor = DmListReactor()
        requestMyInfo.accept(())
        view.backgroundColor = .secondaryBackground
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        requestMemberList.accept(workspace.workspaceId)
        
    }
    
    
    private func configData(ws: WorkSpace) {
        mainView.topView.wsImageView.setImage(with: ws.thumbnail)
        mainView.topView.workSpaceName.text = "Direct Message"//ws.name
        mainView.topView.profileImageView.image = Constants.Image.dummyProfile[UserDefaultsManager.userId % 3]
    }
    
    private func presentPageSheet(vc: UIViewController) {
        let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
        nav.setupBarAppearance()
        present(nav, animated: true)
    }
}

extension DMListViewController: View {
    
    func bind(reactor: DmListReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: DmListReactor) {
        requestMemberList
            .map { Reactor.Action.requestMemberList(wsId: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestDmList
            .map { Reactor.Action.requestDmList(wsId: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        enterDmRoom
            .map { Reactor.Action.enterDmRoom(wsId: $0.workspaceID, roomId: $0.roomID, userId: $0.user.userId) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestMyInfo
            .map { Reactor.Action.requestMyInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectUserCell
            .map { Reactor.Action.selectUserCell(wsId: self.workspace?.workspaceId, user: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: DmListReactor) {
        reactor.state
            .map { $0.msg }
            .asDriver(onErrorJustReturn: "")
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .bottom)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loginRequest }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(with: self) { owner, value in
                print("LoginRequest ", value)
            }
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.memberInfo }
            .asDriver(onErrorJustReturn: [])
            .filter { $0 != .none }
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                if let value = value {
                    if value.isEmpty {
                        owner.mainView.noWorkspaceMember(isEmpty: true)
                    } else {
                        owner.member = value.map {
                            DmItems(items: $0)
                        }
                        owner.updateSnapshot()
                        owner.mainView.noWorkspaceMember(isEmpty: false)
//                        owner.requestDmList.accept(owner.workspace?.workspaceId)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dmList }
            .asDriver(onErrorJustReturn: [])
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                owner.chatData = value.sorted(by: { value1, value2 in
                    value1.createdAt > value2.createdAt
                })
                    .map {
                    DmItems(items: $0)
                }
                owner.updateSnapshot()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dmInfo }
            .filter { $0.0 != .none }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.enterDmData.accept(value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userInfo }
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
            
    }
    
    private func bindEvent() {
        
        enterDmData
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
        
        
        mainView.noMemberView.inviteMemberButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                 let vc = InviteViewController()
                vc.workspace = owner.workspace
                vc.complete = {
                    owner.requestMemberList.accept(owner.workspace?.workspaceId)
                    owner.showToastMessage(message: WorkspaceToastMessage.successInvite.message, position: .bottom)
                }
                owner.presentPageSheet(vc: vc)
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexPath in
                if indexPath.section == 0 { // 멤버 섹션
                    
                    if let user = owner.member[indexPath.item].items as? User {
                        owner.selectUserCell.accept(user)
                    }
                } else if indexPath.section == 1{ // 채팅 섹션
                    if let dm = owner.chatData[indexPath.item].items as? DMsRoom {
                        owner.enterDmRoom.accept(dm)
                        owner.requestUserInfo.accept(dm.user.userId)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
    }
    
}

extension DMListViewController {
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<DmSection, DmItems>()
        snapshot.appendSections([.member, .chat])
        snapshot.appendItems(member, toSection: .member)
        snapshot.appendItems(chatData, toSection: .chat)
        mainView.dataSource.apply(snapshot)
    }
 
    
    
}
