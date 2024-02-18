//
//  OnBoardingView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

final class OnBoardingView: BaseView {
    
    private let imageView = UIImageView().then {
        $0.image = Constants.Image.onBoarding
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleView = UIImageView().then {
        $0.image = Constants.Image.splash
        $0.contentMode = .scaleAspectFit
    }
    
    let startButton = CustomButton(bgColor: Constants.Color.mainColor, title: "시작하기")
    
    override func configure() {
        super.configure()
        addSubview(titleView)
        addSubview(imageView)
        addSubview(startButton)
    }
    override func setConstraints() {
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(93)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        startButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(Constants.Design.buttonHeight)
        }
    }
    
}
