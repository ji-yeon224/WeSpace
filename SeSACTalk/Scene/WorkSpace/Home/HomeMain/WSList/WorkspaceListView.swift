//
//  WorkspaceListView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit

final class WorkspaceListView: BaseView {
    
    let backView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
    }
    
    
    override func configure() {
        backgroundColor = .clear
        
        addSubview(backView)
    }
    
    override func setConstraints() {
        backView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
        }
    }
    
}
