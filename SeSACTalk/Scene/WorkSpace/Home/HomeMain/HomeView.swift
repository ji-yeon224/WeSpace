//
//  HomeView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class HomeView: BaseView {
    
    let topView = HomeTopView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.backgroundColor = .white
    }
    
    
    let alphaView = UIView().then {
        $0.backgroundColor = .alpha
        $0.isHidden = true
    }
    var dataSource: UICollectionViewDiffableDataSource<WorkspaceType, WorkspaceItem>!
    
    
    var newMsgButton = CustomButton(image: .newMessage)
    
    override func configure() {
        backgroundColor = .white
        [topView, collectionView, alphaView, newMsgButton].forEach {
            addSubview($0)
        }
        configureDataSource()
        
    }
    
    override func setConstraints() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.top.horizontalEdges.equalToSuperview()
            //            make.top.equalTo(safeAreaLayoutGuide)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        alphaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        newMsgButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(safeAreaLayoutGuide).inset(16)
            make.size.equalTo(54)
        }
    }
    
}

extension HomeView {
    
    private func createLayout() -> UICollectionViewLayout {
        let section = UICollectionViewCompositionalLayout { indexPath, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            
            
            
            config.itemSeparatorHandler = { indexPath, sectionSeparatorConfiguration in
                var configuration = sectionSeparatorConfiguration
                if indexPath.row == 0 && indexPath.section != 0 {
                    configuration.topSeparatorVisibility = .visible
                } else {
                    configuration.topSeparatorVisibility = .hidden
                }
                configuration.bottomSeparatorVisibility = .hidden
                
                return configuration
            }
            
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            
            section.interGroupSpacing = 5
            
            var contentInsets = section.contentInsets
            
            contentInsets.top = 0
            contentInsets.bottom = 5
            section.contentInsets = contentInsets
            
            return section
        }
        return section
    }
    private func configureDataSource() {
        
        let titleCell = UICollectionView.CellRegistration<UICollectionViewListCell, WorkspaceItem> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.valueCell()
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
        let bottomCell = UICollectionView.CellRegistration<WorkspaceCollectionViewCell, String> { cell, indexPath, itemIdentifier in
            cell.titleLabel.text = itemIdentifier
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
            } else if itemIdentifier.plus != nil {
                return collectionView.dequeueConfiguredReusableCell(using: bottomCell, for: indexPath, item: itemIdentifier.plus)
            }
            else {
                let cell = collectionView.dequeueConfiguredReusableCell(using: titleCell, for: indexPath, item: itemIdentifier)
                return cell
            }
            
        })
    }
}
