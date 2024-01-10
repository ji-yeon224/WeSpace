//
//  HomeView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class HomeView: BaseView {
    
    let topView = HomeTopView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout()).then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
    var dataSource: UICollectionViewDiffableDataSource<WorkspaceType, WorkspaceItem>!
    
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
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        
         let layout = UICollectionViewFlowLayout()
         layout.minimumLineSpacing = 8
         layout.minimumInteritemSpacing = 8
         let size = UIScreen.main.bounds.width - 10 //self.frame.width - 40
         layout.itemSize = CGSize(width: size, height: 50)
         layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
         
        
        return layout
    }
    
    private func configureDataSource() {
        
        let titleCell = UICollectionView.CellRegistration<UICollectionViewListCell, WorkspaceItem> { cell, indexPath, itemIdentifier in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = itemIdentifier.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            cell.contentConfiguration = contentConfiguration
            
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
            
        }
        
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
            if itemIdentifier.subItems.count == 0 {
                let cell = collectionView.dequeueConfiguredReusableCell(using: channelCell, for: indexPath, item: itemIdentifier.item)
                return cell
            } else {
                let cell = collectionView.dequeueConfiguredReusableCell(using: titleCell, for: indexPath, item: itemIdentifier)
                return cell
            }
            
//            guard let cell = collectionView.dequeueConfiguredReusableCell(using: channelCell, for: indexPath, item: itemIdentifier.item) as? WorkspaceCollectionViewCell else {
//                return UICollectionViewCell()
//            }
//            print(itemIdentifier.item?.name)
//            
//            return cell
//            if let channel = itemIdentifier.item as? Channel {
//                let cell = collectionView.dequeueConfiguredReusableCell(using: channelCell, for: indexPath, item: channel)
//                return cell
//            }
//            else if let dm = itemIdentifier.item as? DM {
//                let cell = collectionView.dequeueConfiguredReusableCell(using: dmCell, for: indexPath, item: dm)
//                return cell
//            }
//            else if let newFriend = itemIdentifier.item as? NewFriend {
//                let cell = collectionView.dequeueConfiguredReusableCell(using: newFriendCell, for: indexPath, item: newFriend)
//                return cell
//            }
//            return UICollectionViewCell()
            
        })
    }
}
