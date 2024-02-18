//
//  CoinCollectionCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import UIKit
import RxSwift

final class CoinCollectionCell: BaseCollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    let cellTitle = CustomBasicLabel(text: "", fontType: .bodyBold)
    let coinCountLabel = CustomBasicLabel(text: "", fontType: .bodyBold, color: .brand).then {
        $0.isHidden = true
    }
    let subTitle =  CustomBasicLabel(text: "", fontType: .body, color: .secondaryText).then {
        $0.text = "코인이란?"
        $0.isHidden = true
    }
    let buyButton = CustomButton(bgColor: .brand, title: "").then {
        $0.isHidden = true
    }
    
    override func configure() {
        super.configure()
        contentView.backgroundColor = .secondaryBackground
        [cellTitle, coinCountLabel, subTitle, buyButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinCountLabel.isHidden = true
        subTitle.isHidden = true
        buyButton.isHidden = true
        disposeBag = DisposeBag()
    }
    
    override func setConstraints() {
        cellTitle.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(15)
            make.verticalEdges.equalTo(contentView).inset(13)
        }
        coinCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(cellTitle.snp.trailing).offset(5)
            make.verticalEdges.equalTo(contentView).inset(13)
        }
        subTitle.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(10)
            make.height.equalTo(22)
            make.centerY.equalTo(contentView)
        }
        buyButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(10)
            make.height.equalTo(28)
            make.width.equalTo(74)
            make.centerY.equalTo(contentView)
        }
    }
    
    func setCellComponents(section: Int) {
        if section == 0 {
            coinCountLabel.isHidden = false
            subTitle.isHidden = false
            
        } else {
            buyButton.isHidden = false
        }
    }
}
