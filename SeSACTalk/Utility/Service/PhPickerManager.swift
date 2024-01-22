//
//  PhPickerManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import UIKit
import PhotosUI
import RxSwift

final class PHPickerManager {
    
    static let shared = PHPickerManager()
    private init() { }
    private weak var viewController: UIViewController?
    
    private let group = DispatchGroup()
    var prevSelectId: [String] = []
    private var selections = [String : PHPickerResult]()
    let selectedImage = PublishSubject<([String], [UIImage])>()
    var disposeBag = DisposeBag()
    
    func presentPicker(vc: UIViewController, selectLimit: Int = 1, selectedId: [String]? = nil) {
        self.viewController = vc
        self.disposeBag = DisposeBag()
        let filter = PHPickerFilter.images
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .ordered
        configuration.selectionLimit = selectLimit
        
        if let id = selectedId {
            configuration.preselectedAssetIdentifiers = id
            
            prevSelectId = id
        } else {
            selections.removeAll()
            prevSelectId.removeAll()
        }
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController?.present(picker, animated: true)
    }
}

extension PHPickerManager: PHPickerViewControllerDelegate {
  
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard let viewController else {return}
        print("finisih ", results.count)
        
        var newSelections = [String: PHPickerResult]()
                    
        results.forEach {
            guard let id = $0.assetIdentifier else { return }
            newSelections[id] = selections[id] ?? $0
        }
        
        selections = newSelections
        prevSelectId = results.compactMap { $0.assetIdentifier }
        if selections.isEmpty {
            selectedImage.onNext(([], []))
        } else {
            setImage()
            
        }
        picker.dismiss(animated: true)
    }
    
    private func setImage() {
        var imageDict: [String: UIImage] = [:]
        var imageList: [UIImage] = []
        
        
        for (id, result) in selections {
            self.group.enter()
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { item, error in
                    guard let img = item as? UIImage else {
                        return
                    }
                    
                    imageDict[id] = img
                    self.group.leave()
                }
            }
            
            
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.prevSelectId.forEach {
                guard let img = imageDict[$0] else { return }
                imageList.append(img)
            }
            print(prevSelectId)
            selectedImage.onNext((prevSelectId, imageList))
        }

        
        
    }
}

