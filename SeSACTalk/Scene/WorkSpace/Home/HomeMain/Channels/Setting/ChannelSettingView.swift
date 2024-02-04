//
//  ChannelSettingView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import UIKit


final class ChannelSettingView: BaseView {
    
    let scrollView = UIScrollView().then {
        $0.updateContentView()
    }
    
    private lazy var stackView = {
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

    lazy var collectionView = ChannelMemberCollectionView(frame: .zero, collectionViewLayout: self.createLayout(userCnt: 0))
    
    private let editView = UIView()
    private let exitView = UIView()
    private let changeView = UIView()
    private let deleteView = UIView()
    
    let editButton = CustomButton(bgColor: .white, borderColor: .black, titleColor: .basicText,title: Text.editChannelTitle)
    
    let exitButton = CustomButton(bgColor: .white, borderColor: .black, titleColor: .basicText, title: Text.exitChannelTitle)
    let changeButton = CustomButton(bgColor: .white, borderColor: .black, titleColor: .basicText, title: Text.changeChannelTitle)
    let deleteButton = CustomButton(bgColor: .white, borderColor: .error, titleColor: .error, title: Text.deleteChannelTitle)
    
    func configDummyData() {
        channelNameLabel.text = "# channelName"
        descriptionLabel.text = "채널 설명 어쩌구 저쩌구 아아아ㅏ아아아ㅏ아아아ㅏ아아아ㅏㅇㄴ이ㅏ닝니아니ㅏㅇ나이니ㅏdfsaasdfee나ㅓㅇ"
        
    }
    
    override func configure() {
        super.configure()
//        collectionView.collectionViewLayout = compostionalViewLayout()
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        [nameBackView, descBackView, collectionView, editView, exitView, changeView, deleteView].forEach {
            stackView.addArrangedSubview($0)
        }
//        collectionBackView.addSubview(collectionView)
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
        collectionView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(50)
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
    func createLayout(userCnt: Int) -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let topItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0)))
            let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize, repeatingSubitem: topItem, count: 1)
            
            let userItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5),
                                                   heightDimension: .fractionalHeight(1.0)))
            
            
            let userGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            
            let userGroup = NSCollectionLayoutGroup.horizontal(layoutSize: userGroupSize, repeatingSubitem: userItem, count: 5)
            
            var memberGroup: [NSCollectionLayoutItem] = [topGroup]
            for _ in 0...(userCnt/5+1) {
                memberGroup.append(userGroup)
            }

            let nestedGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(200)),
                subitems: memberGroup)
            let section = NSCollectionLayoutSection(group: nestedGroup)
            return section
            
        }
        
        return layout
    }
    
    
    private func configDataSource() {
        
        let titleCell = UICollectionView.CellRegistration<UICollectionViewListCell, ChannelMemberItem> { cell, indexPath, itemIdentifier in
            
            var config = UIListContentConfiguration.valueCell()
            config.text = itemIdentifier.title
            config.textProperties.font = Font.title2.fontStyle
            config.textProperties.color = .basicText
            
            cell.contentConfiguration = config
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header, tintColor: Constants.Color.black)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .clear
            cell.backgroundConfiguration = backgroundConfig
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
                let cell = collectionView.dequeueConfiguredReusableCell(using: memberCell, for: indexPath, item: itemIdentifier.item)
                
                return cell
            } else {
                let cell = collectionView.dequeueConfiguredReusableCell(using: titleCell, for: indexPath, item: itemIdentifier)
                
                
                return cell
                
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
        editView.isHidden = !isAdmin
        changeView.isHidden = !isAdmin
        deleteView.isHidden = !isAdmin
    }
    
}
