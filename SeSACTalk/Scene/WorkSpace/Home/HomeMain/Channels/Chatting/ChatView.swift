//
//  ChatView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit

final class ChatView: BaseView {
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: compostionalViewLayout()).then {
        $0.contentInset = .init(top: 5, left: 0, bottom: 0, right: 0)
    }
    var dataSource: UICollectionViewDiffableDataSource<String, ChannelMessage>!
    
    private let bottomView = UIStackView().then {
        $0.backgroundColor = .white
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: .zero, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    let chatWriteView = ChatWriteView()
    
    override func configure() {
        backgroundColor = Constants.Color.secondaryBG
        
        addSubview(collectionView)
        addSubview(bottomView)
        bottomView.addArrangedSubview(chatWriteView)
        configureDataSource()
    }
    
    override func setConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(bottomView.snp.top).offset(-5)
        }
        
        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-8)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let size = Constants.Design.deviceWidth - 32
        layout.itemSize = CGSize(width: size, height: 100)
        return layout
    }
    
    private func compostionalViewLayout() -> UICollectionViewLayout {
        let size = Constants.Design.deviceWidth - 32
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        
        return layout
    }
    
    
    
    private func configureDataSource() {
        let cell = UICollectionView.CellRegistration<ChattingCell, ChannelMessage>  { cell, indexPath, itemIdentifier in
            
            cell.nickNameLabel.text = itemIdentifier.user.nickname
            if let profileImg = itemIdentifier.user.profileImage {
                cell.profileImageView.setImage(with: profileImg)
            } else {
                let img = Constants.Image.dummyProfile.shuffled()
                cell.profileImageView.image = img.randomElement()
            }
            cell.chatTextLabel.text = itemIdentifier.content
            cell.timeLabel.text = itemIdentifier.createdAt.convertToTimeString            
        }
        dataSource = UICollectionViewDiffableDataSource<String, ChannelMessage>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
            cell.layoutIfNeeded()
            return cell
        })
    }
    
}
