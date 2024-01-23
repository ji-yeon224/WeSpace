//
//  ImageMessageView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/23/24.
//

import UIKit
import Kingfisher

final class ImageMessageView: BaseView {
    
    let imageView1 = SquareFillImageView(frame: .zero).then {
        $0.tag = 1
    }
    let imageView2 = SquareFillImageView(frame: .zero).then {
        $0.tag = 2
    }
    let imageView3 = SquareFillImageView(frame: .zero).then {
        $0.tag = 3
    }
    lazy var imageView4 = SquareFillImageView(frame: .zero).then {
        $0.tag = 4
    }
    lazy var imageView5 = SquareFillImageView(frame: .zero).then {
        $0.tag = 5
    }
    
    private let imageStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fillEqually
    }
    
    private let firstStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.distribution = .fillEqually
    }
    private let secondStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.distribution = .fillEqually
    }
    
    let oneImageView =  SquareFillImageView(frame: .zero).then {
        $0.tag = 1
        $0.isHidden = true
    }
    
    
    override func configure() {
        
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(imageStackView)
        addSubview(oneImageView)
        imageStackView.addArrangedSubview(firstStack)
        imageStackView.addArrangedSubview(secondStack)
        
        [imageView1, imageView2, imageView3].forEach {
            firstStack.addArrangedSubview($0)
        }
        [imageView4, imageView5].forEach {
            secondStack.addArrangedSubview($0)
        }
        
    }
    
    override func setConstraints() {
        imageStackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        firstStack.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.33)
        }
        oneImageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func configImage(files: [String]) {
        switch files.count {
        case 1:
            imageStackView.isHidden = true
            oneImageView.isHidden = false
            oneImageView.setImage(with: files[0])
        case 2:
            
            imageView1.setImage(with: files[0])
            
            imageView2.setImage(with: files[1])
            secondStack.isHidden = true
            imageView3.isHidden = true
        case 3:
            imageView1.setImage(with: files[0])
            imageView2.setImage(with: files[1])
            imageView3.setImage(with: files[2])
            secondStack.isHidden = true
            
        case 4:
            imageView1.setImage(with: files[0])
            imageView2.setImage(with: files[1])
            imageView4.setImage(with: files[2])
            imageView5.setImage(with: files[3])
            
            imageView3.isHidden = true
        case 5:
            
            imageView1.setImage(with: files[0])
            imageView2.setImage(with: files[1])
            imageView3.setImage(with: files[2])
            imageView4.setImage(with: files[3])
            imageView5.setImage(with: files[4])
        default: break
        }
        
    }
    
    
    
    
}
