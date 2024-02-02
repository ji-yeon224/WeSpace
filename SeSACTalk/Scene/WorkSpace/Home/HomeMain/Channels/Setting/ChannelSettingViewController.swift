//
//  ChannelSettingViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import UIKit
import ReactorKit

final class ChannelSettingViewController: BaseViewController {
    
    private let mainView = ChannelSettingView()
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        super.configure()
        configNav()
        title = "채널 설정"
        mainView.configDummyData()
        mainView.setButtonHidden(isAdmin: true)
        
        
        let user = [
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "1111", profileImage: nil)),
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "2222", profileImage: nil)),
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "3333", profileImage: nil)),
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "4444", profileImage: nil)),
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "1111", profileImage: nil)),
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "2222", profileImage: nil)),
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "3333", profileImage: nil)),
            ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "3333", profileImage: nil))
        ]
        let item = ChannelMemberItem(title: "멤버", subItems: user, item: nil)
        updateSnapShot(item: item)
        
    }
    
    
    
    
}

extension ChannelSettingViewController {
    
    private func updateSnapShot(item: ChannelMemberItem) {
        mainView.collectionView.collectionViewLayout = mainView.createLayout(userCnt: item.subItems.count)
        let snapshot = initialSnapshot(items: [item])
        mainView.dataSource.apply(snapshot, to: "", animatingDifferences: false)
        
        
        
        
    }
    
    
    private func initialSnapshot(items: [ChannelMemberItem]) -> NSDiffableDataSourceSectionSnapshot<ChannelMemberItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<ChannelMemberItem>()
        
        snapshot.append(items, to: nil)
        for item in items where !item.subItems.isEmpty {
            snapshot.append(item.subItems, to: item)
            if item.subItems.count > 1 {
                snapshot.expand(items)
            }
        }
       
        return snapshot
    }
}

extension ChannelSettingViewController {
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
