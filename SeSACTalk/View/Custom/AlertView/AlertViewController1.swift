//
//  AlertViewController1.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class AlertViewController1: UIViewController {
    private var titleText: String?
    private var messageText: String?
    private var contentView: UIView?
    private let disposeBag = DisposeBag()
    
    private let alertView = UIView().then {
        $0.backgroundColor = Constants.Color.secondaryBG
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    private let contentStackView = CustomStackView().then {
        $0.spacing = 10
    }
    private let stackView = CustomStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    private lazy var titleLabel = CustomBasicLabel(text: titleText ?? "asdfasdf", fontType: .title2, line: 0).then {
        $0.textAlignment = .center
    }
    private lazy var messageLabel = CustomBasicLabel(text: messageText ?? "asdfsdf", fontType: .body, color: Constants.Color.secondaryText, line: 0)
    
    convenience init(titleText: String? = nil,
                     messageText: String? = nil
    ) {
        self.init()

        self.titleText = titleText
        self.messageText = messageText
        modalPresentationStyle = .overFullScreen
    }

    convenience init(contentView: UIView) {
        self.init()

        self.contentView = contentView
        modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setConstraints()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.alertView.transform = .identity
            self?.alertView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.alertView.transform = .identity
            self?.alertView.isHidden = true
        }
    }
    
    public func addActionToButton(title: String? = nil,
                                  backgroundColor: UIColor = .brand,
                                  completion: (() -> Void)? = nil) {
        let button = CustomButton(bgColor: backgroundColor, title: title ?? "")

        button.rx.tap
            .bind(with: self) { owner, _ in
                completion?()
            }
            .disposed(by: disposeBag)
       

        stackView.addArrangedSubview(button)
    }
    
    private func configure() {
        view.addSubview(alertView)
        alertView.addSubview(contentStackView)
        alertView.addSubview(stackView)
        [titleLabel, messageLabel].forEach {
            contentStackView.addArrangedSubview($0)
        }
        view.backgroundColor = .alpha
    }
    
    private func setConstraints() {
        alertView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        contentStackView.snp.makeConstraints { make in
            make.centerX.equalTo(alertView)
            make.horizontalEdges.lessThanOrEqualTo(alertView).inset(16)
            make.top.equalTo(alertView).inset(16)
        }
        stackView.snp.makeConstraints { make in
            make.height.equalTo(Constants.Design.buttonHeight)
            make.top.equalTo(contentStackView.snp.bottom).offset(16)
            make.bottom.horizontalEdges.equalTo(alertView).inset(16)
        }
        
        
    }
    
}
