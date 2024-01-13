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
    let alphaView = UIView().then {
        $0.backgroundColor = .alpha
        $0.isHidden = true
    }
    var dataSource: UICollectionViewDiffableDataSource<WorkspaceType, WorkspaceItem>!
    
    override func configure() {
        backgroundColor = .white
        [topView, collectionView, alphaView].forEach {
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
        alphaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
            contentConfiguration.textProperties.font = Font.title2.fontStyle
            cell.contentConfiguration = contentConfiguration
            
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header, tintColor: Constants.Color.black)
            
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
            
            
        }
        
        let channelCell = UICollectionView.CellRegistration<WorkspaceCollectionViewCell, Channel> { cell, indexPath, itemIdentifier in
            cell.titleLabel.text = itemIdentifier.name
            cell.imageView.image = .hashTagThin
        }
        let dmCell = UICollectionView.CellRegistration<WorkspaceCollectionViewCell, DMsRoom> { cell, indexPath, itemIdentifier in
            cell.titleLabel.text = itemIdentifier.user.nickname
            cell.imageView.image = .seSACBot
        }
        let newFriendCell = UICollectionView.CellRegistration<WorkspaceCollectionViewCell, NewFriend> { cell, indexPath, itemIdentifier in
            cell.titleLabel.text = "팀원 추가"
            cell.imageView.image = .plus
        }
        
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            
            if itemIdentifier.item != nil {
                if let channel = itemIdentifier.item as? Channel {
                    return collectionView.dequeueConfiguredReusableCell(using: channelCell, for: indexPath, item: channel)
                }
                else if let dm = itemIdentifier.item as? DMsRoom {
                    return collectionView.dequeueConfiguredReusableCell(using: dmCell, for: indexPath, item: dm)
                }
                else if let newFirend = itemIdentifier.item as? NewFriend {
                    return collectionView.dequeueConfiguredReusableCell(using: newFriendCell, for: indexPath, item: newFirend)
                }
                else {
                    return UICollectionViewCell()
                }
            } else {
                let cell = collectionView.dequeueConfiguredReusableCell(using: titleCell, for: indexPath, item: itemIdentifier)
                return cell
            }
            
        })
    }
}
