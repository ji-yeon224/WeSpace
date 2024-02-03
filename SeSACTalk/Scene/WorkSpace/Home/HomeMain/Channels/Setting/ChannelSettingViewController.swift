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
    private let disposeBag = DisposeBag()
    var user = [
        ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "1111", profileImage: nil)),
        ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "2222", profileImage: nil)),
        ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "3333", profileImage: nil))
    ]
    
    lazy var item = ChannelMemberItem(title: "멤버", subItems: user, item: nil)
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(snapshot.isVisible(item))
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.user.append(ChannelMemberItem(title: "", subItems: [], item: User(userId: 1, email: "aa", nickname: "4444", profileImage: nil)))
            self.item = ChannelMemberItem(title: "멤버", subItems: self.user, item: nil)
            self.updateSnapShot(item: self.item)
        }
        
        
    }
    
    override func configure() {
        super.configure()
        configNav()
        title = "채널 설정"
        updateSnapShot(item: item)
        mainView.configDummyData()
        mainView.setButtonHidden(isAdmin: true)
        
        bindEvent()
        
        
    }
    
    private func bindEvent() {
        mainView.collectionView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexPath in
                if indexPath.item == 0 {
                    owner.mainView.scrollView.updateContentView()
                    owner.mainView.collectionView.layoutIfNeeded()
                    
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    
    
}

extension ChannelSettingViewController {
    
    private func updateSnapShot(item: ChannelMemberItem) {
        mainView.collectionView.collectionViewLayout = mainView.createLayout(userCnt: item.subItems.count)
        let snapshot = initialSnapshot(items: [item])
        mainView.dataSource.apply(snapshot, to: "", animatingDifferences: false)
//        mainView.updateCollectionViewHeight()
        
//        mainView.layoutIfNeeded()
        
    }
    
    
    private func initialSnapshot(items: [ChannelMemberItem]) -> NSDiffableDataSourceSectionSnapshot<ChannelMemberItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<ChannelMemberItem>()
        
        snapshot.append(items, to: nil)
        for item in items where !item.subItems.isEmpty {
            snapshot.append(item.subItems, to: item)
            snapshot.expand(items)
            
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


