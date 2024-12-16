//
//  SourceManager.swift
//  News
//
//  Created by Dzmitry on 15.12.24.
//

import Foundation

final class SourceManager {
    
    // MARK: - Properties
    static let shared = SourceManager()
    private var sourceList = [Source]()
    
    // MARK: - Init
    private init() {}
    
}

// MARK: - Open methods
extension SourceManager {
    
    func allSources() -> [Source] {
        return sourceList
    }
    
    func isEnabledSources() -> [Source] {
        return sourceList.filter { $0.isEnabled }
    }
    
    func createSources(from jsonObjects: [[String: String]]) {
        for object in jsonObjects {
            guard
                let name = object["name"],
                let url = object["url"]
            else {
                continue
            }
            
            if !sourceList.contains(where: { $0.name == name }) {
                let newSource = SourceFactory.createUniqueSource(name: name, url: url)
                sourceList.append(newSource)
            }
        }
    }
    
}
