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
//            make.width.equalTo(self).multipliedBy(0.6)
        }
        firstStack.snp.makeConstraints { make in
            make.height.equalTo(firstStack.snp.width).multipliedBy(0.33)
        }
        oneImageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
//            make.width.equalTo(Constants.Design.deviceWidth * 0.6)
//            make.height.equalTo(oneImageView.snp.width).multipliedBy(0.66)
        }
    }
    
    func initImageView() {
        imageStackView.isHidden = false
        oneImageView.isHidden = true
        secondStack.isHidden = false
        firstStack.isHidden = false
        oneImageView.image = nil
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
        imageView4.image = nil
        imageView5.image = nil
        imageView1.isHidden = false
        imageView2.isHidden = false
        imageView3.isHidden = false
        imageView4.isHidden = false
        imageView5.isHidden = false
    }
    
    func configUIImage(img: [UIImage]) {
        switch img.count {
        case 1:
            imageStackView.isHidden = true
            oneImageView.isHidden = false
            oneImageView.image = img[0]
        case 2:
            imageView1.image = img[0]
            imageView2.image = img[1]
            
            secondStack.isHidden = true
            imageView3.isHidden = true
            
        case 3:
            imageView1.image = img[0]
            imageView2.image = img[1]
            imageView3.image = img[2]
            secondStack.isHidden = true
            
        case 4:
            imageView1.image = img[0]
            imageView2.image = img[1]
            imageView4.image = img[2]
            imageView5.image = img[3]
            
            imageView3.isHidden = true
        case 5:
            
            imageView1.image = img[0]
            imageView2.image = img[1]
            imageView3.image = img[2]
            imageView4.image = img[3]
            imageView5.image = img[4]
            
            imageStackView.isHidden = false
            
        default: break
        }
    }
    
    func configImage(files: [String]) {
        switch files.count {
        case 1:
            imageStackView.isHidden = true
            oneImageView.isHidden = false
            oneImageView.setImage(with: files[0])
        case 2:
            oneImageView.isHidden = true
            imageView1.setImage(with: files[0])
            
            imageView2.setImage(with: files[1])
            secondStack.isHidden = true
            imageView3.isHidden = true
        case 3:
            oneImageView.isHidden = true
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
