//
//  Spotlight.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 10/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices

struct Spotlight {
    
    static let domainIdentifier = "com.travlendar.spotlight"
    
    static func addItem(identifier: String, title: String, description: String, addedData: Date? = nil, keywords: [String] = []) {
        if #available(iOS 9.0, *) {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeMessage as String)
            
            attributeSet.title = title
            attributeSet.contentDescription = description
            attributeSet.keywords = keywords
            if addedData != nil {
                attributeSet.contentCreationDate = addedData!
            }
            
            let item = CSSearchableItem(uniqueIdentifier: "\(identifier)", domainIdentifier: Spotlight.domainIdentifier, attributeSet: attributeSet)
            
            CSSearchableIndex.default().indexSearchableItems([item]) { error in
                if let error = error {
                    print("Spotlight addItem error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    static func removeItem(identifier: String) {
        if #available(iOS 9.0, *) {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(identifier)"]) { error in
                if let error = error {
                    print("Spotlight removeItem error: \(error.localizedDescription)")
                }
            }
        }
    }
    
}

