//
//  InitialView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit

final class InitialView: BaseView {
    
    private let completedLabel = CustomBasicLabel(text: "출시 준비 완료!", fontType: .title1)
    private let completedMessage = CustomBasicLabel(text: Text.completMessage, fontType: .body, line: 0)
    private let completImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = .launching
        return view
    }()
    let makeButton = CustomButton(bgColor: .customGreen, title: Text.makeWorkspace)
    
    override func configure() {
        super.configure()
        [completedLabel, completedMessage, completImageView, makeButton].forEach {
            addSubview($0)
        }
        completedLabel.textAlignment = .center
        completedMessage.textAlignment = .center
    }
    
    override func setConstraints() {
        completedLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(30)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(24)
            
        }
        completedMessage.snp.makeConstraints { make in
            make.top.equalTo(completedLabel.snp.bottom).offset(24)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(24)
//            make.bottom.equalTo(completImageView.snp.top).offset(15)
        }
        completImageView.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(completImageView.snp.width)
        }
        makeButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(Constants.Design.buttonHeight)
//            make.bottom.equalTo(safeAreaLayoutGuide).offset(24)
        }
    }
}
