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
    
    let imageStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fillEqually
    }
    
    let firstStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.distribution = .fillEqually
    }
    let secondStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.distribution = .fillEqually
    }
    
    private var files = [String].init()
    
    init(files: [String]?) {
        super.init(frame: .zero)
        guard let files = files else { return }
        self.files = files
        print(files.count)
//        [imageView1, imageView2, imageView3, imageView4, imageView5].forEach {
//            $0.isHidden = false
//        }
        imageView3.isHidden = true
//        fiveImageView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func configure() {
        
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(imageStackView)
        imageStackView.addArrangedSubview(firstStack)
        imageStackView.addArrangedSubview(secondStack)
        
        [imageView1, imageView2, imageView3].forEach {
            firstStack.addArrangedSubview($0)
        }
        [imageView4, imageView5].forEach {
            secondStack.addArrangedSubview($0)
        }
        print("!!", files.count)
        switch files.count {
        case 0:
            [imageView1, imageView2, imageView3, imageView4, imageView5].forEach {
                $0.isHidden = false
            }
        case 1:
            imageView1.isHidden = false
            imageView1.setImage(with: files[0])
        case 2:
            imageView1.isHidden = false
            imageView1.setImage(with: files[0])
            imageView2.isHidden = false
            imageView2.setImage(with: files[1])
        case 3:
            imageView1.isHidden = false
            imageView1.setImage(with: files[0])
            imageView2.isHidden = false
            imageView2.setImage(with: files[1])
            imageView3.isHidden = false
            imageView3.setImage(with: files[2])
        case 4:
            imageView1.isHidden = false
            imageView1.setImage(with: files[0])
            imageView2.isHidden = false
            imageView2.setImage(with: files[1])
            imageView4.isHidden = false
            imageView4.setImage(with: files[2])
            imageView5.isHidden = false
            imageView5.setImage(with: files[3])
        case 5:
            imageView1.isHidden = false
            imageView1.setImage(with: files[0])
            imageView2.isHidden = false
            imageView2.setImage(with: files[1])
            imageView3.isHidden = false
            imageView3.setImage(with: files[2])
            imageView4.isHidden = false
            imageView4.setImage(with: files[3])
            imageView5.isHidden = false
            imageView5.setImage(with: files[4])
        default: break
        }
        
        
        
        
    }
    
    override func setConstraints() {
        imageStackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        firstStack.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.33)
        }
    }
    
    
    private func oneImageView() {
        imageView1.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.6)
        }
    }
    
    private func twoImageView() {
        imageView1.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.4)
        }
        imageView2.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.4)
        }
    }
    
    private func threeImageView() {
        imageView1.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.5)
        }
        imageView2.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.5)
        }
        imageView3.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.5)
        }
    }
    
    private func fourImageView() {
        imageView1.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.4)
        }
        imageView2.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.4)
        }
        imageView4.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.4)
        }
        imageView5.snp.makeConstraints { make in
            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.4)
        }
    }
    
    private func fiveImageView() {
//        imageView1.snp.makeConstraints { make in
//            make.height.equalTo(imageView1.snp.width)//.multipliedBy(0.5)
//        }
//        imageView2.snp.makeConstraints { make in
//            make.height.equalTo(imageView2.snp.width)//.multipliedBy(0.5)
//        }
//        imageView3.snp.makeConstraints { make in
//            make.height.equalTo(imageView3.snp.width)//.multipliedBy(0.5)
//        }
//        imageView4.snp.makeConstraints { make in
//            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.4)
//        }
//        imageView5.snp.makeConstraints { make in
//            make.height.equalTo(imageStackView.snp.width).multipliedBy(0.6)
//        }
    }
    
}
