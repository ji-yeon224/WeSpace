//
//  MyProfileView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/13/24.
//

import UIKit

final class MyProfileView: BaseView {
    
    let profileImageView = EditImageView().then {
        $0.image = Constants.Image.dummyProfile[UserDefaultsManager.userId % 3]
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    var dataSource: UICollectionViewDiffableDataSource<MyProfileSection, MyProfileEditItem>!
    
    override func configure() {
        super.configure()
        [profileImageView, collectionView].forEach {
            addSubview($0)
        }
        configDataSource()
    }
    
    override func setConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.size.equalTo(78)
        }
        
        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
            make.top.equalTo(profileImageView.snp.bottom).offset(5)
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
        let cell = UICollectionView.CellRegistration<ProfileEditCell, MyProfileEditItem> { cell, indexPath, itemIdentifier in
            cell.setCellLayout(type: itemIdentifier.type)
            cell.cellTitle.text = itemIdentifier.type.rawValue
            if let subText = itemIdentifier.subText {
                cell.subTitle.text = subText
            } else if let email = itemIdentifier.email {
                cell.emailLabel.text = email
            }
            if let vendor = itemIdentifier.vendor {
                print(vendor)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        })
    }
}
