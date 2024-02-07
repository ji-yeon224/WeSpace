//
//  DMListViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit

final class DMListViewController: BaseViewController {
    
    private var workspaceId: Int?
    private var mainView = DMListView()
    
    private var member: [DmItems] = []
    private var chatData: [DmItems] = []
    
    override func loadView() {
        self.view = mainView
    }
    
    init(wsId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.workspaceId = wsId
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("dmvc")
        dummyData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("dmvw")
    }
    
    override func configure() {
//        super.configure()
        view.backgroundColor = .secondaryBackground
        navigationController?.navigationBar.isHidden = true
        
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
        updateSnapshot(section: .member)
        updateSnapshot(section: .chat)
        
    }
    
    private func updateSnapshot(section: DmSection) {
        var snapshot = NSDiffableDataSourceSnapshot<DmSection, DmItems>()
        snapshot.appendSections([.member, .chat])
        snapshot.appendItems(member, toSection: .member)
        snapshot.appendItems(chatData, toSection: .chat)
        mainView.dataSource.apply(snapshot)
    }
    
}
