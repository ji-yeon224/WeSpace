//
//  WorkspaceListView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit

final class WorkspaceListView: BaseView {
    
    private let backView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
    }
    
    private let topView = UIView().then {
        $0.backgroundColor = .secondaryBackground
    }
    
    
    override func configure() {
        backgroundColor = .clear
        
        addSubview(backView)
        
        [topView].forEach {
            backView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        backView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
            make.width.equalTo(Constants.Design.deviceWidth / 1.3)
        }
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(98)
            make.top.horizontalEdges.equalToSuperview()
            
        }
        
    }
    
}
