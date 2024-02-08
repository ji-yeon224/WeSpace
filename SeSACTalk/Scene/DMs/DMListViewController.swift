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
    private var requestMemberList = PublishRelay<Int>()
    
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
//        print("dmvc")
//        dummyData()
    }
    
    
    override func configure() {
//        super.configure()
        guard let workspace = workspace else { return }
        configData(ws: workspace)
        self.reactor = DmListReactor()
        view.backgroundColor = .secondaryBackground
        navigationController?.navigationBar.isHidden = true
        requestMemberList.accept(workspace.workspaceId)
    }
    
    
    private func configData(ws: WorkSpace) {
        mainView.topView.wsImageView.setImage(with: ws.thumbnail)
        mainView.topView.workSpaceName.text = ws.name
        mainView.topView.profileImageView.image = Constants.Image.dummyProfile[UserDefaultsManager.userId % 3]
    }
}

extension DMListViewController: View {
    
    func bind(reactor: DmListReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: DmListReactor) {
        requestMemberList
            .map { Reactor.Action.requestMemberList(wsId: $0)}
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
        
        // 멤버 없으면 empty view 보여줘야함
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
