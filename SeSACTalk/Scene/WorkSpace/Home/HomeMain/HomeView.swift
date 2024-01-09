//
//  HomeView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class HomeView: BaseView {
    
    let topView = HomeTopView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
//    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, MyPageContent>!
    var dataSource: UICollectionViewDiffableDataSource<WorkspaceType, AnyHashable>!
    
    override func configure() {
        backgroundColor = .white
        [topView, collectionView].forEach {
            addSubview($0)
        }
        configureDataSource()
    }
    
    override func setConstraints() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
}

extension HomeView {
    private func collectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        
        return layout
    }
    
    private func configureDataSource() {
        
        let channelCell = UICollectionView.CellRegistration<WorkspaceCollectionViewCell, Channel> { cell, indexPath, itemIdentifier in
            cell.titleLabel.text = itemIdentifier.name
            cell.imageView.image = .hashTagThin
        }
        let dmCell = UICollectionView.CellRegistration<WorkspaceCollectionViewCell, DM> { cell, indexPath, itemIdentifier in
            cell.titleLabel.text = itemIdentifier.name
            cell.imageView.image = .seSACBot
        }
        let newFriendCell = UICollectionView.CellRegistration<WorkspaceCollectionViewCell, NewFriend> { cell, indexPath, itemIdentifier in
            cell.titleLabel.text = "팀원 추가"
            cell.imageView.image = .plus
        }
        
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            if let channel = itemIdentifier as? Channel {
                let cell = collectionView.dequeueConfiguredReusableCell(using: channelCell, for: indexPath, item: channel)
                return cell
            }
            else if let dm = itemIdentifier as? DM {
                let cell = collectionView.dequeueConfiguredReusableCell(using: dmCell, for: indexPath, item: dm)
                return cell
            }
            else if let newFriend = itemIdentifier as? NewFriend {
                let cell = collectionView.dequeueConfiguredReusableCell(using: newFriendCell, for: indexPath, item: newFriend)
                return cell
            }
            return UICollectionViewCell()
            
        })
    }
}
