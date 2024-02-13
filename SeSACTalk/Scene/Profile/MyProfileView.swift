//
//  MyProfileView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/13/24.
//

import UIKit
import RxDataSources

final class MyProfileView: BaseView {
    
    let profileImageView = EditImageView().then {
        $0.image = Constants.Image.dummyProfile[UserDefaultsManager.userId % 3]
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(ProfileEditCell.self, forCellWithReuseIdentifier: ProfileEditCell.identifier)
    }
    
    var rxdataSource: RxCollectionViewSectionedReloadDataSource<MyProfileSectionModel>!
    
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
        
        rxdataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileEditCell.identifier, for: indexPath) as? ProfileEditCell else { return UICollectionViewCell() }
            
            cell.setCellLayout(type: item.type)
            cell.cellTitle.text = item.type.rawValue
            if let subText = item.subText {
                cell.subTitle.text = subText
            } else if let email = item.email {
                cell.emailLabel.text = email
            }
            if let coin = item.coin {
                cell.coinCountLabel.text = "\(coin)"
            }
            if let vendor = item.vendor {
                print(vendor)
            }
            
            return cell
        })
    }
    
    func setProfileImage(value: String?) {
        if let value = value {
            profileImageView.imageView.setImage(with: value)
        } else {
            profileImageView.imageView.image = Constants.Image.dummyProfile[UserDefaultsManager.userId % 3]
        }
    }
}
