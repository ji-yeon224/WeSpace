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
    
    let titleView = {
        let view = UIImageView()
        view.image = Constants.Image.splash
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func configure() {
        super.configure()
        addSubview(titleView)
        addSubview(imageView)
    }
    override func setConstraints() {
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(93)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}
