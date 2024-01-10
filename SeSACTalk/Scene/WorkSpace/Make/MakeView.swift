//
//  MakeView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit

final class MakeView: BaseView {
    
    let imageView = EditImageView()
    
    let workSpaceName = CommonFormView(title: "워크스페이스 이름", placeholder: Text.makeSpaceNamePH)
    let workSpaceDesc = CommonFormView(title: "워크스페이스 설명", placeholder: Text.makeSpaceDescPH)
    let completeButton =  CustomButton(bgColor: .inactive, title: "완료").then {
        $0.isEnabled = false
    }
    override func configure() {
        super.configure()
        [imageView, workSpaceName, workSpaceDesc, completeButton].forEach {
            addSubview($0)
        }
    }
    
    override func setConstraints() {
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.size.equalTo(78)
            
        }
        
        workSpaceName.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(imageView.snp.bottom).offset(16)
        }
        
        workSpaceDesc.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self).inset(24)
            make.top.equalTo(workSpaceName.snp.bottom).offset(24)
        }
        completeButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(Constants.Design.buttonHeight)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-24)
        }
    }
    
    func setEnableButton(isEnable: Bool) {
        completeButton.isEnabled = isEnable
        let color = isEnable ? Constants.Color.mainColor : Constants.Color.inActive
        completeButton.backgroundColor = color
    }
}
