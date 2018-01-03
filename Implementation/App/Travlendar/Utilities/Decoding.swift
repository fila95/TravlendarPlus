//
//  Decoding.swift
//  Utilities
//
//  Created by Giovanni Filaferro on 03/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import Foundation


extension KeyedDecodingContainer {
    func decodeWrapper<T>(key: K, defaultValue: T) throws -> T
        where T : Decodable {
            return try decodeIfPresent(T.self, forKey: key) ?? defaultValue
    }
}
