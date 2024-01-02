//
//  OnBoardingView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

final class OnBoardingView: BaseView {
    
    let imageView = {
        let view = UIImageView()
        view.image = Constants.Image.onBoarding
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let title = {
        let view = UILabel()
        view.textColor = Constants.Color.basicText
        
        view.font = Constants.Design.title1Font
        view.setTextWithLineHeight(text: "새싹톡을 사용하면 어디서나 팀을 모을 수 있습니다.", fontType: .title1)
        view.numberOfLines = 0
        return view
    }()
    
    override func configure() {
        super.configure()
        addSubview(title)
        addSubview(imageView)
    }
    override func setConstraints() {
        title.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(30)
//            make.height.equalTo(50)
        }
        imageView.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
        }
    }
    
}
