//
//  DMListView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit

final class DMListView: BaseView {
    
    let topView = HomeTopView()
    
    let noMemberView = NoMemberDmView()
    
    override func configure() {
//        super.configure()
        backgroundColor = .secondaryBackground
        [topView, noMemberView].forEach {
            addSubview($0)
        }
    }
    
    override func setConstraints() {
        topView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.top.horizontalEdges.equalToSuperview()
            
        }
        
        noMemberView.snp.makeConstraints { make in
//            make.top.equalTo(topView.snp.bottom)
            make.width.equalTo(self).multipliedBy(0.7)
            make.center.equalTo(self)
        }
        
    }
    
}
