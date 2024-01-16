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

enum setWSType {
    case create, edit
}

final class MakeViewController: BaseViewController, View {
    
    private let mainView = MakeView()
    var disposeBag: DisposeBag = DisposeBag()
    var delegate: MakeWSDelegate?
    
    private var mode: setWSType = .create
    private var wsInfo: WorkSpace?
    private var img: UIImage?
    
    init(mode: setWSType = .create, info: WorkSpace? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.mode = mode
        self.wsInfo = info
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = MakeViewReactor()
    }
    
    override func configure() {
        super.configure()
        configNav()
        switch mode {
        case .create:
            title = "워크스페이스 생성"
        case .edit:
            title = "워크스페이스 편집"
            configEditData()
        }
        
        
    }
    
    private func configEditData() {
        if let ws = wsInfo {
            mainView.imageView.imageView.setImage(with: ws.thumbnail)
            self.img = mainView.imageView.imageView.image
            mainView.workSpaceName.textfield.text = ws.name
            mainView.workSpaceDesc.textfield.text = ws.description
        }
        mainView.completeButton.setTitle("저장", for: .normal)
        
        
    }
    
    func bind(reactor: MakeViewReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: MakeViewReactor) {
        
        mainView.imageView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                PHPickerManager.shared.presentPicker(vc: owner)
            }
            .disposed(by: disposeBag)
        PHPickerManager.shared.selectedImage
            .bind(with: self) { owner, image in
                if !image.isEmpty {
                    owner.mainView.imageView.setImage(img: image[0])
                    owner.img = owner.mainView.imageView.image
                }
            }
            .disposed(by: disposeBag)
        
        mainView.workSpaceName.textfield.rx.text.orEmpty
            .map { Reactor.Action.nameInput(name: $0) }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        let input = Observable.combineLatest(mainView.workSpaceName.textfield.rx.text.orEmpty, mainView.workSpaceDesc.textfield.rx.text.orEmpty)
        
        mainView.completeButton.rx.tap
            .withLatestFrom(input) { _, value in
                return value
            }
            .map { value -> MakeViewReactor.Action in
                print(self.mode)
                if self.mode == .create {
                    return Reactor.Action.createButtonTap(name: value.0, description: value.1, image: SelectImage(img: self.img))
                }else {
                    return Reactor.Action.editButtonTap(name: value.0, description: value.1, image: SelectImage(img: self.img), id: self.wsInfo?.workspaceId)
                }
            }
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
            .observe(on:MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                if let value = value.0 {
                    let nav = UINavigationController(rootViewController: HomeTabBarController(workspace: value))
                    owner.view.window?.rootViewController = nav
                    owner.view.window?.makeKeyAndVisible()
                }
               
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.completeEdit }
            .filter{ $0.1 == true }
            .observe(on:MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                if let value = value.0 {
                    owner.dismiss(animated: true)
                    owner.delegate?.editComplete(data: value)
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

