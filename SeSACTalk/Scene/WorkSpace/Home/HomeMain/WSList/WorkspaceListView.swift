//
//  WorkspaceListView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit

final class WorkspaceListView: BaseView {
    
    private let backView = UIView().then {
        $0.backgroundColor = Constants.Color.background
        $0.layer.cornerRadius = 25
    }
    private let divider = UIView().then {
        $0.backgroundColor = .seperator
    }
    
    private let topView = UIView().then {
        $0.backgroundColor =  Constants.Color.background
    }
    
    private let titleLabel = CustomBasicLabel(text: "워크스페이스", fontType: .title1)
    
    let emptyView = WorkspaceEmptyView()
    
    let addWorkspaceView = WorkspaceListSettingView(img: .plus, title: "워크스페이스 추가")
    let helpView = WorkspaceListSettingView(img: .help, title: "도움말")
    
    
    override func configure() {
        backgroundColor = .clear
        
        addSubview(backView)
        
        [topView, divider, emptyView, addWorkspaceView, helpView].forEach {
            backView.addSubview($0)
        }
        
        topView.addSubview(titleLabel)
    }
    
    override func setConstraints() {
        backView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
            make.width.equalTo(Constants.Design.deviceWidth / 1.3)
        }
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalTo(backView)
            make.top.equalTo(safeAreaLayoutGuide)
        }
        setTopViewConstraints()
        
        helpView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(backView)
            make.height.equalTo(41)
        }
        addWorkspaceView.snp.makeConstraints { make in
            make.bottom.equalTo(helpView.snp.top)
            make.horizontalEdges.equalTo(backView)
            make.height.equalTo(41)
        }
        
    }
    
    private func setTopViewConstraints() {
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(topView).inset(16)
            make.leading.equalTo(topView).inset(18)
        }
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
}
