//
//  Alert.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func show(title: String, message: String, buttonTitle: String, complection: @escaping ()->() = {}, on viewController: UIViewController) {
        let ac = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        ac.addAction(UIAlertAction.init(
            title: buttonTitle,
            style: UIAlertActionStyle.default,
            handler: { (action) in
                complection()
        }))
        
        viewController.present(ac, animated: true, completion: nil)
    }
}

