//
//  NSUserDefaults+ArchivedArray.swift
//
//  Created by David O'Reilly on 2016/05/14.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation

/**
 Allow saving arrays in NSUserDefaults
 */
extension UserDefaults {

    func setArchivedArray(_ array: [AnyObject]?, forKey key: String) {
        if let array = array {
            let archivedObject = NSKeyedArchiver.archivedData(withRootObject: array)
            set(archivedObject, forKey: key)
        } else {
            set(nil, forKey: key)
        }
    }

    func archivedArrayForKey(_ key: String) -> [AnyObject]? {
        if let unarchivedObject = UserDefaults.standard.object(forKey: key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [AnyObject]
        }
        return nil
    }
}
