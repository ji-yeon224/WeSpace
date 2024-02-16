//
//  DMListView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit

final class DMListView: BaseView {
    
    let topView = HomeTopView()
    
    let noMemberView = NoMemberDmView().then {
        $0.isHidden = true
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    var dataSource: UICollectionViewDiffableDataSource<DmSection, DmItems>!
    
    override func configure() {
        backgroundColor = .secondaryBackground
        [topView, noMemberView, collectionView].forEach {
            addSubview($0)
        }
        
        configDataSource()
    }
    
    override func setConstraints() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.top.horizontalEdges.equalToSuperview()
            
        }
        
        noMemberView.snp.makeConstraints { make in
            make.width.equalTo(self).multipliedBy(0.7)
            make.center.equalTo(self)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        
    }
    
    func noWorkspaceMember(isEmpty: Bool) {
        noMemberView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func configDataSource() {
        let memberCell = UICollectionView.CellRegistration<DmMemberCell, User> { cell, indexPath, itemIdentifier in
            if let profileImg = itemIdentifier.profileImage {
                cell.profileImageView.setImage(with: profileImg)
            } else {
                let img = Constants.Image.dummyProfile
                cell.profileImageView.image = img[itemIdentifier.userId%3]
            }
            cell.nickNameLabel.text = itemIdentifier.nickname
            
        }
        
        let chatCell = UICollectionView.CellRegistration<DmChatCell, DMsRoom> { cell, indexPath, itemIdentifier in
            let user = itemIdentifier.user
            if let profileImage = user.profileImage {
                cell.profileImageView.setImage(with: profileImage)
            } else {
                let img = Constants.Image.dummyProfile
                cell.profileImageView.image = img[user.userId % 3]
            }
            cell.nickNameLabel.text = user.nickname
            cell.messagelabel.text = "메세지"
            if itemIdentifier.unread > 0 {
                cell.unreadView.isHidden = false
                cell.unreadView.countLabel.text = "\(itemIdentifier.unread)"
            } else {
                cell.unreadView.isHidden = true
            }
            if Date.isTodayDate(compareDate: itemIdentifier.createdAt) {
                cell.timeLabel.text = String().convertDateFormat(format: .fullDate, to: .time2, date: itemIdentifier.createdAt)
            } else {
                cell.timeLabel.text = String().convertDateFormat(format: .fullDate, to: .yearByLan, date: itemIdentifier.createdAt)
            }
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if let member = itemIdentifier.items as? User {
                return collectionView.dequeueConfiguredReusableCell(using: memberCell, for: indexPath, item: member)
            } else if let chat = itemIdentifier.items as? DMsRoom {
                return collectionView.dequeueConfiguredReusableCell(using: chatCell, for: indexPath, item: chat)
            } else { return UICollectionViewCell() }
        })
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIdx, layoutEnvironment in
            
            guard let section = DmSection(rawValue: sectionIdx) else { return nil }
            
//            print(section)
            if section == .member {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(76), heightDimension: .absolute(98))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: 10, bottom: .zero, trailing: 10)
                section.orthogonalScrollingBehavior = .continuous
                
                
                
                return section
                
            } else {
                
                
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                
                var contentInset = section.contentInsets
                contentInset.top = 30
                section.contentInsets = contentInset
                return section
            }
            
            
        }
        
        return layout
    }
}
