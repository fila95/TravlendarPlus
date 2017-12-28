//
//  Opener.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

public struct Opener {
    
    public struct Link {
        
        public static func redirectToBrowserAndOpen(link: String) {
            
            guard let url = URL(string: link) else {
                print("Opener - can not create URL")
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        public static func openInsideApp(link: String) {
            
        }
    }
}

