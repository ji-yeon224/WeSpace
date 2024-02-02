//
//  ChannelSettingView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import UIKit


final class ChannelSettingView: BaseView {
    
    let scrollView = UIScrollView()
    
    private let stackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = 10
        
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    
    private let nameBackView = UIView()
    private let descBackView = UIView()
    private let channelNameLabel = CustomBasicLabel(text: "", fontType: .title2)
    private let descriptionLabel = CustomBasicLabel(text: "'", fontType: .body, line: 0)
    
    var dataSource: UICollectionViewDiffableDataSource<String, ChannelMemberItem>!
    
    lazy var collectionView = ChannelMemberCollectionView(frame: .zero, collectionViewLayout: self.compostionalViewLayout())
    
    private let editView = UIView()
    private let exitView = UIView()
    private let changeView = UIView()
    private let deleteView = UIView()
    
    let editButton = CustomButton(bgColor: .white, borderColor: .black, titleColor: .basicText,title: Text.editChannelTitle).then {
        $0.isHidden = true
    }
    let exitButton = CustomButton(bgColor: .white, borderColor: .black, titleColor: .basicText, title: Text.exitChannelTitle)
    let changeButton = CustomButton(bgColor: .white, borderColor: .black, titleColor: .basicText, title: Text.changeChannelTitle).then {
        $0.isHidden = true
    }
    let deleteButton = CustomButton(bgColor: .white, borderColor: .error, titleColor: .error, title: Text.deleteChannelTitle).then {
        $0.isHidden = true
    }
    
    func configDummyData() {
        channelNameLabel.text = "# channelName"
        descriptionLabel.text = "채널 설명 어쩌구 저쩌구 아아아ㅏ아아아ㅏ아아아ㅏ아아아ㅏㅇㄴ이ㅏ닝니아니ㅏㅇ나이니ㅏ너엄니어ㅏ너아넝나ㅓ아너아너아너아ㅓㅓ나어fasdfasdfasdfaszdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdffesdffdsdfsaasdfee나ㅓㅇ"
        
    }
    
    override func configure() {
        super.configure()
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        [nameBackView, descBackView, collectionView, editView, exitView, changeView, deleteView].forEach {
            stackView.addArrangedSubview($0)
        }
        nameBackView.addSubview(channelNameLabel)
        descBackView.addSubview(descriptionLabel)
        editView.addSubview(editButton)
        exitView.addSubview(exitButton)
        changeView.addSubview(changeButton)
        deleteView.addSubview(deleteButton)
        
        configDataSource()
    }
    
    override func setConstraints() {
        
        scrollView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.horizontalEdges.top.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(scrollView)
            make.top.equalTo(scrollView).inset(16)
        }
        
        channelNameLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(nameBackView).inset(16)
            make.verticalEdges.equalTo(nameBackView)
        }
        
        descBackView.snp.makeConstraints { make in
            make.width.equalTo(scrollView.snp.width)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            
            make.horizontalEdges.equalTo(descBackView).inset(16)
            make.verticalEdges.equalTo(descBackView)
        }
        
        editButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(editView)
            make.horizontalEdges.equalTo(editView).inset(24)
            make.height.equalTo(44)
        }
        exitButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(exitView)
            make.horizontalEdges.equalTo(exitView).inset(24)
            make.height.equalTo(44)
        }
        changeButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(changeView)
            make.horizontalEdges.equalTo(changeView).inset(24)
            make.height.equalTo(44)
        }
        deleteButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(deleteView)
            make.horizontalEdges.equalTo(deleteView).inset(24)
            make.height.equalTo(44)
        }
    }
    
    private func compostionalViewLayout() -> UICollectionViewFlowLayout {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        let size = Constants.Design.deviceWidth - 60
        layout.itemSize = CGSize(width: size / 5, height: size / 5)
        
        return layout
    }
    
    private func configDataSource() {
        
        let titleCell = UICollectionView.CellRegistration<UICollectionViewListCell, ChannelMemberItem> { cell, indexPath, itemIdentifier in
            var config = UIListContentConfiguration.valueCell()
            config.text = itemIdentifier.title
            config.textProperties.font = Font.title2.fontStyle
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header, tintColor: Constants.Color.black)
            
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
        }
        
        let memberCell = UICollectionView.CellRegistration<ChannelMemberCell, User> { cell, indexPath, itemIdentifier in
            cell.nameLabel.text = itemIdentifier.nickname
            if let profileImg = itemIdentifier.profileImage {
                cell.profileImageView.setImage(with: profileImg)
            } else {
                let img = Constants.Image.dummyProfile
                cell.profileImageView.image = img[itemIdentifier.userId%3]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            if itemIdentifier.item != nil {
                return collectionView.dequeueConfiguredReusableCell(using: memberCell, for: indexPath, item: itemIdentifier.item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: titleCell, for: indexPath, item: itemIdentifier)
            }
        })
        
        
        
    }
    
    func setChannelInfo(name: String, description: String?) {
        channelNameLabel.text = "# " + name
        if let description = description {
            descriptionLabel.text = description
        }
    }
    
    func setButtonHidden(isAdmin: Bool) {
        if isAdmin {
            editButton.isHidden = false
            changeButton.isHidden = false
            deleteButton.isHidden = false
        }
    }
    
}
