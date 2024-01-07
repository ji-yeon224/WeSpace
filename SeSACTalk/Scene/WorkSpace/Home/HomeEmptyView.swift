//
//  HomeEmptyView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit

final class HomeEmptyView: BaseView {
    
    let topView = HomeTopView()
    
    private let noWorkSpaceLabel =  CustomBasicLabel(text: Text.noWorkSpaceTitle, fontType: .title1).then {
        $0.textAlignment = .center
    }
    
    private let message = CustomBasicLabel(text: Text.noWorkSpace, fontType: .body, line: 0).then {
        $0.textAlignment = .center
    }
    private let noWorkSpaceImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .emptySpace
    }
    let makeButton = CustomButton(bgColor: .customGreen, title: Text.makeWorkspace)
    
    override func configure() {
        super.configure()
        
        [topView,noWorkSpaceLabel, message, noWorkSpaceImageView, makeButton].forEach {
            addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
        }
        noWorkSpaceLabel.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(30)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        message.snp.makeConstraints { make in
            make.top.equalTo(noWorkSpaceLabel.snp.bottom).offset(24)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        noWorkSpaceImageView.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(noWorkSpaceImageView.snp.width)
        }
        makeButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(Constants.Design.buttonHeight)
        }
    }
    
}
