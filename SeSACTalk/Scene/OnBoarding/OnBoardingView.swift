//
//  OnBoardingView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

final class OnBoardingView: BaseView {
    
    private let imageView = {
        let view = UIImageView()
        view.image = Constants.Image.onBoarding
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let titleView = {
        let view = UIImageView()
        view.image = Constants.Image.splash
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let startButton = CustomButton(bgColor: Constants.Color.green, title: "시작하기")
    
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
