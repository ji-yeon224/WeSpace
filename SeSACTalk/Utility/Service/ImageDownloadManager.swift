//
//  KinfisherManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/25/24.
//

import Foundation
import Kingfisher

final class ImageDownloadManager {
    
    static let shared = ImageDownloadManager()
    private init() { }
    
    func getUIImage(with urlString: String, completion: ((SelectImage) -> Void)? = nil) {
        ImageCache.default.retrieveImage(forKey: urlString, options: [
            .requestModifier(ImageLoadManager.shared.getModifier())
        ]) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                if let image = value.image {
                    
                    completion?(SelectImage(img: image))
                } else {
                    guard let url = URL(string: self.getPhotoURL(urlString)) else { return }
                    let resource = KF.ImageResource(downloadURL: url, cacheKey: urlString)
                    KingfisherManager.shared.retrieveImage(with: resource, options: [
                        .requestModifier(ImageLoadManager.shared.getModifier())
                    ]) { result in
                        switch result {
                        case .success(let result):
                            completion?(SelectImage(img: result.image))
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            case .failure(let error):
//                self.backgroundColor = Constants.Color.background
                debugPrint(error)
            }
            
        }
        
        
    }
    
    private func getPhotoURL(_ url: String) -> String {
        return BaseURL.baseURL + "/v1" + url
    }
}
