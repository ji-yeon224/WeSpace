//
//  UIImageView+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/12/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(with urlString: String, resize width: CGFloat? = nil, cornerRadius: CGFloat = 15, completion: (() -> Void)? = nil) {
        let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: cornerRadius)
        
        ImageCache.default.retrieveImage(forKey: urlString, options: [
            .requestModifier(ImageLoadManager.shared.getModifier()),
            .transition(.fade(1.0)),
            .processor(cornerImageProcessor)
        ]) { [weak self] result in
            guard let self = self else { return }
            self.kf.indicatorType = .activity
            switch result {
            case .success(let value):
                if let image = value.image {
                    if let width = width {
                        self.image = image.resize(width: width)
                    } else {
                        self.image = image
                    }
                    completion?()
                } else {
                    guard let url = URL(string: self.getPhotoURL(urlString)) else { return }
                    let resource = KF.ImageResource(downloadURL: url, cacheKey: urlString)
                    self.kf.setImage(with: resource, options: [
                        .requestModifier(ImageLoadManager.shared.getModifier()),
                        .transition(.fade(1.0)),
                        .processor(cornerImageProcessor)
                    ]) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let result):
                            if let width = width {
                                self.image = result.image.resize(width: width)
                            } else {
                                self.image = result.image
                            }
                            completion?()
                            
                        case .failure(_):
                            self.backgroundColor = Constants.Color.background
                            
                            
                        }
                        
                    }
                }
            case .failure(let error):
                self.backgroundColor = Constants.Color.background
                debugPrint(error)
            }
            
        }
        
        
        
    }

 
    
    // 서버에서 받을 이미지 full url
    private func getPhotoURL(_ url: String) -> String {
        return BaseURL.baseURL + "/v1" + url
    }
    
}

