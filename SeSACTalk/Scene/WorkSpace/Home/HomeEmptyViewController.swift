//
//  HomeEmptyViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeEmptyViewController: BaseViewController {
    
    private let mainView = HomeEmptyView()
    private let viewModel = HomeEmptyViewModel()
    private let disposeBag = DisposeBag()
    
    private let requestUserInfo = BehaviorRelay(value: true)
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    override func configure() {
        view.backgroundColor = Constants.Color.secondaryBG
    }
    
    func bind() {
        let input = HomeEmptyViewModel.Input(requestUserInfo: requestUserInfo)
        let output = viewModel.transform(input: input)
        
        
    }
}
