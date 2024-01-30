//
//  SearchChannelViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import UIKit
import ReactorKit

final class SearchChannelViewController: BaseViewController {
    
    private let mainView = SearchChannelView()
    
    private let requestChannelList = PublishSubject<Int>()
    private var wsId: Int?
    
    var disposeBag = DisposeBag()
    
    init(wsId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.wsId = wsId
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainView
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "채널 탐색"
    }
    
    
    override func configure() {
        configNav()
        self.reactor = SearchChannelReactor()
        guard let wsId = wsId else {
            showToastMessage(message: "채널 목록을 불러올 수 없습니다.", position: .bottom)
            return
        }
        
        requestChannelList.onNext(wsId)
        
    }
    
    
    
    
    
}

extension SearchChannelViewController: View {
    
    func bind(reactor: SearchChannelReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: SearchChannelReactor) {
        requestChannelList
            .map { Reactor.Action.requestChannelList(wsId: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SearchChannelReactor) {
        
        reactor.state
            .map { $0.channelList }
            .distinctUntilChanged {
                return $0.count == $1.count
            }
            .filter { $0.count != 0 }
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.tableView.rx.items(dataSource: mainView.dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.msg }
            .filter {
                !$0.isEmpty
            }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .bottom)
            }
            .disposed(by: disposeBag)
            
        
    }
    
    
    private func bindEvent() {
 
        
    }
    
}

extension SearchChannelViewController {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
        
        navigationController?.setupBarAppearance()
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}
