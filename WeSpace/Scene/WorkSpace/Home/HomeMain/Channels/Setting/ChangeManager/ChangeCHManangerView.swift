//
//  ChangeCHManangerView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/5/24.
//

import UIKit

final class ChangeCHManangerView: BaseView {
    
    var dataSource: UICollectionViewDiffableDataSource<String, User>!
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
    
    override func configure() {
        super.configure()
        addSubview(collectionView)
        configDataSource()
    }
    
    override func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let size = Constants.Design.deviceWidth
        layout.itemSize = CGSize(width: size, height: 60)
        return layout
    }
    
    func configDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MemberCollectionViewCell, User> { cell, indexPath, itemIdentifier in
            
            
            if let profileImg = itemIdentifier.profileImage {
                cell.memberImageView.setImage(with: profileImg)
            } else {
                let img = Constants.Image.dummyProfile.shuffled()
                cell.memberImageView.image = img.randomElement()
            }
            
            cell.memberNameLabel.text = itemIdentifier.nickname
            cell.emailLabel.text = itemIdentifier.email
            
        }
        
        
        dataSource = UICollectionViewDiffableDataSource<String, User>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            collectionView.layoutIfNeeded()
            return cell
        })
    }
    
}
