//
//  Source.swift
//  News
//
//  Created by Dzmitry on 15.12.24.
//

import Foundation

protocol SourceProtocol {
    var name: String { get }
    var url: String { get }
    var isEnabled: Bool { get set }
    
    func toggle()
}

class Source: SourceProtocol {
    
    // MARK: - Properties
    private lazy var userDefaultsKey = "Source.\(name).isEnabled"
    
    var name: String
    var url: String
    var isEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: userDefaultsKey) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Init
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
}

// MARK: - Open methods
extension Source {
    
    func toggle() {
        isEnabled.toggle()
    }
    
}

// MARK: - Factory
final class SourceFactory {
    
    private final class UniqueSource: Source {
        
        // MARK: - Properties
        let uniqueName: String
        let uniqueUrl: String
        
        // MARK: - Init
        init(uniqueName: String, uniqueUrl: String) {
            self.uniqueName = uniqueName
            self.uniqueUrl = uniqueUrl
            
            super.init(name: uniqueName, url: uniqueUrl)
        }
    }
    
    // MARK: - Open methods
    static func createUniqueSource(name: String, url: String) -> Source {
        UniqueSource(uniqueName: name, uniqueUrl: url)
    }
    
}
