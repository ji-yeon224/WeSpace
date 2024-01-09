//
//  HomeView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class HomeView: BaseView {
    
    let topView = HomeTopView()
    
    override func configure() {
        backgroundColor = .white
        [topView].forEach {
            addSubview($0)
        }
    }
    
    override func setConstraints() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
        }
    }
    
}
