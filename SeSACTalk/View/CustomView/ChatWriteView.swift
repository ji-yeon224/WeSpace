//
//  ChatWriteView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit
import RxCocoa
import RxDataSources

final class ChatWriteView: BaseView {
    
    private let stackView = CustomStackView()
    var delegate: ChatImageSelectDelegate?
    let imageButton = CustomButton(image: .plus).then{
        $0.backgroundColor = .clear
    }
    
    let textView = UITextView().then {
        $0.sizeToFit()
        $0.isScrollEnabled = false
        $0.font = Font.body.fontStyle
        $0.backgroundColor = Constants.Color.background
        $0.translatesAutoresizingMaskIntoConstraints = true
    
        
    }
    
    let placeholder = CustomBasicLabel(text: "메세지를 입력하세요.", fontType: .body, color: .secondaryText, line: 1)
   
    
    let sendButton = CustomButton(image: .sendInactive).then {
        $0.backgroundColor = .clear
    }
    
    lazy var imgCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout()).then {
        $0.register(ChatImageCell.self, forCellWithReuseIdentifier: ChatImageCell.identifier)
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
    }

    var rxDataSource: RxCollectionViewSectionedReloadDataSource<SelectImageModel>!
    
    override func configure() {
        layer.cornerRadius = 8
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(imgCollectionView)
        backgroundColor = Constants.Color.background
        [imageButton, stackView, sendButton].forEach {
            addSubview($0)
        }
        textView.addSubview(placeholder)
        
        configureDataSource()
    }
    
    override func setConstraints() {
        
        imageButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(self).inset(10)
            make.size.equalTo(24)
            make.top.greaterThanOrEqualTo(self).inset(10)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(self).inset(10)
            make.size.equalTo(24)
            make.top.greaterThanOrEqualTo(self).inset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(self).inset(10)
            make.bottom.equalTo(self).inset(10)
            make.leading.equalTo(imageButton.snp.trailing).offset(8)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.top.equalTo(self).inset(10)
        }
        
        textView.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(54)
            make.height.greaterThanOrEqualTo(16)
        }
        
        placeholder.snp.makeConstraints { make in
            make.leading.equalTo(textView).offset(5)
            make.centerY.equalTo(textView)
        }
        
        imgCollectionView.snp.makeConstraints { make in
            make.height.equalTo((Constants.Design.deviceWidth - 60) / 7 )
        }
        
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let size = Constants.Design.deviceWidth - 60 //self.frame.width - 40
        layout.itemSize = CGSize(width: size / 7, height: size / 7)
        
        return layout
    }
    
    private func configureDataSource() {
        let cell = UICollectionView.CellRegistration<ChatImageCell, SelectImage> { cell, indexPath, itemIdentifier in
            cell.imageView.image = itemIdentifier.img
            cell.xButton.rx.tap
                .asDriver()
                .drive(with: self) { owner, _ in
                    owner.delegate?.deleteImage(indexPath: indexPath)
                }
                .disposed(by: cell.disposeBag)
        }
        
        rxDataSource = RxCollectionViewSectionedReloadDataSource<SelectImageModel> { dataSource, collectionView, indexPath, item in
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatImageCell.identifier, for: indexPath) as? ChatImageCell else { return UICollectionViewCell() }
           
            cell.imageView.image = item.img
            cell.xButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.delegate?.deleteImage(indexPath: indexPath)
                }
                .disposed(by: cell.disposeBag)
           
           return cell
       }
        
        
    }
    
    private func compostionalViewLayout() -> UICollectionViewLayout {
        let size = (Constants.Design.deviceWidth - 60) / 5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(size))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(size))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        
        return layout
    }
}
