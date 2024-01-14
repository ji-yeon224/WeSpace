//
//  WorkspaceEmptyView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/14/24.
//

import UIKit

final class WorkspaceEmptyView: BaseView {
    
    private let emptyTitleLabel = CustomBasicLabel(text: Text.noWorkSpaceTitle_small, fontType: .title1, line: 2).then {
        $0.textAlignment = .center
    }
    
    private let emptyMessage = CustomBasicLabel(text: Text.noWorkSpace_small, fontType: .body, line: 3).then {
        $0.textAlignment = .center
    }
    
    let makeButton = CustomButton(bgColor: .brand, title: Text.makeWorkspace)
    
    
    override func configure() {
        super.configure()
        backgroundColor = Constants.Color.secondaryBG
        [emptyTitleLabel, emptyMessage, makeButton].forEach {
            addSubview($0)
        }
        
        
    }
    
    override func setConstraints() {
        
        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self).inset(183)
            make.horizontalEdges.equalTo(self).inset(24)
        }
        
        emptyMessage.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(19)
            make.horizontalEdges.equalTo(self).inset(24)
        }
        
        makeButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(emptyMessage.snp.bottom).offset(10)
            make.height.equalTo(Constants.Design.buttonHeight)
        }
    }
    
}
