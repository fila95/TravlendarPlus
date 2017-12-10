//
//  Share.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

public struct Share {
    
    public struct Native {
        
        static func share(text: String? = nil, fileNames: [String] = [], complection: ((_ isSharing: Bool)->())? = nil, sourceView: UIView, on viewController: UIViewController) {
            
            var shareData: [Any] = []
            if text != nil {
                shareData.append(text!)
            }
            
            for file in fileNames {
                let path = Bundle.main.path(forResource: file, ofType: "")
                if path != nil {
                    let fileData = URL.init(fileURLWithPath: path!)
                    shareData.append(fileData)
                }
            }
            
            let shareViewController = UIActivityViewController(activityItems: shareData, applicationActivities: nil)
            shareViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    complection?(false)
                    return
                }
                complection?(true)
            }
            shareViewController.modalPresentationStyle = .popover
            shareViewController.popoverPresentationController?.sourceView = sourceView
            shareViewController.popoverPresentationController?.sourceRect = sourceView.bounds
            
            viewController.present(shareViewController, animated: true, completion: nil)
        }
    }
}

