//
//  PageSheetManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/3/24.
//

import UIKit

final class PageSheetManager {
    static func sheetPresentation(_ vc: UIViewController, detent: UISheetPresentationController.Detent) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: vc)
//        nav.setupBarAppearance()
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [detent]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
        }
        return nav
        
        
    }
    
    static func customDetent(_ vc: UIViewController, height: CGFloat) -> UINavigationController {
        let detentIdentifier = UISheetPresentationController.Detent.Identifier("customDetent")
        let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
            // safe area bottom을 구하기 위한 선언.
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let safeAreaBottom = windowScene?.windows.first?.safeAreaInsets.bottom ?? 0

            return height - safeAreaBottom
        }
        
        return self.sheetPresentation(vc, detent: customDetent)
    }
}
