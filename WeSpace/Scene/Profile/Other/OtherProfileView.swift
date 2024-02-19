//
//  OtherProfileView.swift
//  WeSpace
//
//  Created by 김지연 on 2/19/24.
//

import UIKit

final class OtherProfileView: BaseView {
    
    let profileImageView = SquareFillImageView(frame: .zero)
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    var dataSource: UICollectionViewDiffableDataSource<String, OtherProfileItem>!
    
    override func configure() {
        super.configure()
        [profileImageView, collectionView].forEach {
            addSubview($0)
        }
        configDataSource()
    }
    
    override func setConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(80)
            make.height.equalTo(profileImageView.snp.width)
            make.top.equalTo(safeAreaLayoutGuide).inset(30)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(15)
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
            
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = false
        configuration.backgroundColor = .background
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
    
    private func configDataSource() {
        let cell = UICollectionView.CellRegistration<ProfileCell, OtherProfileItem> { cell, indexPath, itemIdentifier in
            cell.cellTitle.text = itemIdentifier.title
            cell.subTitle.text = itemIdentifier.subText
            cell.backgroundColor = .secondaryBackground
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        })
    }
}
