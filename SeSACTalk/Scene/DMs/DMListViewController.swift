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
//        print("dmvc")
//        dummyData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func configure() {
//        super.configure()
        guard let workspace = workspace else { return }
        configData(ws: workspace)
        self.reactor = DmListReactor()
        view.backgroundColor = .secondaryBackground
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        requestMemberList.accept(workspace.workspaceId)
    }
    
    
    private func configData(ws: WorkSpace) {
        mainView.topView.wsImageView.setImage(with: ws.thumbnail)
        mainView.topView.workSpaceName.text = ws.name
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
                        owner.requestDmList.accept(owner.workspace?.workspaceId)
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
                owner.chatData = value.map {
                    DmItems(items: $0)
                }
                owner.updateSnapshot()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dmInfo }
            .filter {
                $0.0 != .none
            }
            .bind(with: self) { owner, value in
                let vc = DmChatViewController(myInfo: nil, dmInfo: value.0, dmChatItem: value.1)
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
            
    }
    
    private func bindEvent() {
        mainView.noMemberView.inviteMemberButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                 let vc = InviteViewController()
                vc.workspace = owner.workspace
                vc.complete = {
                    owner.requestMemberList.accept(owner.workspace?.workspaceId)
                    self.showToastMessage(message: WorkspaceToastMessage.successInvite.message, position: .bottom)
                }
                owner.presentPageSheet(vc: vc)
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexPath in
                if indexPath.section == 0 { // 멤버 섹션
                    
                    if let user = owner.member[indexPath.item].items as? User {
                        print(user)
                    }
                } else if indexPath.section == 1{ // 채팅 섹션
                    if let dm = owner.chatData[indexPath.item].items as? DMsRoom {
                        owner.enterDmRoom.accept(dm)
                    }
                }
            }
            .disposed(by: disposeBag)
        
//        enterDmRoom
//            .bind(with: self) { owner, value in
//                // db 조회, wsId
//                let vc = DmChatViewController(myInfo: nil, dmInfo: value)
//                vc.hidesBottomBarWhenPushed = true
//                owner.navigationController?.pushViewController(vc, animated: true)
//            }
//            .disposed(by: disposeBag)
        
        
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
    
    private func dummyData() {
        member = [
        DmItems(items: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁaaaqqqa", profileImage: nil)),
        DmItems(items: User(userId: 2, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil)),
        DmItems(items: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil)),
        DmItems(items: User(userId: 3, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil)),
        DmItems(items: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil)),
        DmItems(items: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil)),
        DmItems(items: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil)),
        DmItems(items: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil))
        ]
        chatData = [
        DmItems(items: DMsRoom(workspaceID: 1, roomID: 1, createdAt: "2023-12-21T22:47:30.236Z", user: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil), unread: 0)),
        DmItems(items: DMsRoom(workspaceID: 1, roomID: 1, createdAt: "2024-02-07T22:47:30.236Z", user: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁaaaaa", profileImage: nil), unread: 3)),
        DmItems(items: DMsRoom(workspaceID: 1, roomID: 1, createdAt: "2023-12-21T22:47:30.236Z", user: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil), unread: 0)),
        DmItems(items: DMsRoom(workspaceID: 1, roomID: 1, createdAt: "2023-12-21T22:47:30.236Z", user: User(userId: 1, email: "ㅁㅁ", nickname: "ㅁㅁ", profileImage: nil), unread: 0))
        ]
//        updateSnapshot(section: .member)
//        updateSnapshot(section: .chat)
        
    }
    
    
}
