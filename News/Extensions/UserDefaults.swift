//
//  UserDefaults.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

extension UserDefaults {
    
    private enum Keys: String {
        case refreshInterval
        case isCompactMode
        case isNeedToClearCache
    }
    
    // MARK: - Properties
    var refreshInterval: Int {
        get {
            return self.integer(forKey: Keys.refreshInterval.rawValue)
        }
        set {
            self.set(newValue, forKey: Keys.refreshInterval.rawValue)
        }
    }
    
    var isCompactMode: Bool {
        get {
            return self.bool(forKey: Keys.isCompactMode.rawValue)
        }
        set {
            self.set(newValue, forKey: Keys.isCompactMode.rawValue)
        }
    }
    
    var isNeedToClearCache: Bool {
        get {
            return self.bool(forKey: Keys.isNeedToClearCache.rawValue)
        }
        set {
            self.set(newValue, forKey: Keys.isNeedToClearCache.rawValue)
        }
    }
    
}
