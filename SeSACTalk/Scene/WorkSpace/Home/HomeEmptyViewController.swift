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
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func configure() {
        view.backgroundColor = Constants.Color.secondaryBG
    }
}
