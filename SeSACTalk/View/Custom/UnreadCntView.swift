//
//  UnreadCntView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class UnreadCntView: BaseView {
    
    private let stackView = UIStackView()
    private let backView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = Constants.Color.mainColor
    }
    let countLabel = CustomBasicLabel(text: "0", fontType: .caption, color: .white, line: 1).then {
        $0.textAlignment = .center
    }
    
    override func configure() {
        backgroundColor = .clear
        addSubview(stackView)
        stackView.addArrangedSubview(backView)
        backView.addSubview(countLabel)
    }
    
    override func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        backView.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.height.equalTo(20)
        }
        countLabel.snp.makeConstraints { make in
            make.edges.equalTo(backView).inset(5)
        }
    }
    
    
}
