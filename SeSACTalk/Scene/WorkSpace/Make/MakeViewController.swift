//
//  MakeViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit
import RxGesture
import ReactorKit
import RxCocoa

final class MakeViewController: BaseViewController, View {
    
    private let mainView = MakeView()
    var disposeBag: DisposeBag = DisposeBag()
    
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = MakeViewReactor()
    }
    
    override func configure() {
        super.configure()
        title = "워크스페이스 생성"
        configNav()
    }
    
    func bind(reactor: MakeViewReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: MakeViewReactor) {
        
        mainView.imageView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                PHPickerManager.shared.presentPicker(vc: self)
            }
            .disposed(by: disposeBag)
        PHPickerManager.shared.selectedImage
            .bind(with: self) { owner, image in
                if !image.isEmpty {
                    owner.mainView.imageView.setImage(img: image[0])
                }
            }
            .disposed(by: disposeBag)
        
        mainView.workSpaceName.textfield.rx.text.orEmpty
            .map { Reactor.Action.nameInput(name: $0) }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
       
        Observable.combineLatest(mainView.completeButton.rx.tap, mainView.workSpaceName.textfield.rx.text.orEmpty) { _, value in
            value
        }
        .withLatestFrom(mainView.workSpaceDesc.textfield.rx.text.orEmpty) { name, desc in
            return (name, desc)
        }
        .map { Reactor.Action.completeButtonTap(name: $0.0, description: $0.1, image: SelectImage(img: self.mainView.wsImage))}
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
    }
    
    
    private func bindState(reactor: MakeViewReactor) {
        reactor.state
            .map { $0.buttonEnable }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                owner.mainView.setEnableButton(isEnable: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.msg }
            .distinctUntilChanged()
            .filter({ value in
                value.count > 0
            })
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .top)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.completeCreate }
            .filter { $0.1 == true }
            .bind(with: self) { owner, value in
                if let value = value.0 {
                    let nav = UINavigationController(rootViewController: HomeTabBarController(workspace: value))
                    owner.view.window?.rootViewController = nav
                    owner.view.window?.makeKeyAndVisible()
                }
               
            }
            .disposed(by: disposeBag)
    }
    
    
}

extension MakeViewController {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}

