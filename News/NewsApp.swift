//
//  NewsApp.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import SwiftData
import SwiftUI

@main
struct NewsApp: App {
    
    // MARK: - Properties
    let container: ModelContainer
    let viewModel: NewsViewModel
    
    // MARK: - Init methods
    init() {
        do {
            container = try ModelContainer(for: NewsItem.self)
            let actor = ThreadsafeActor(modelContainer: container)
            
            if UserDefaults.standard.isNeedToClearCache {
                Task {
                    await actor.clearCache()
                }
            }
            
            viewModel = NewsViewModel(modelContainer: container)
        } catch {
            fatalError("Failed to create container")
        }
    }
    
    // MARK: UI
    var body: some Scene {
        WindowGroup {
            NewsView(viewModel: viewModel)
        }
    }
    
}
