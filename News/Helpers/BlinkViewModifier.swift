//
//  BlinkViewModifier.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import SwiftUI

struct BlinkViewModifier: ViewModifier {
    
    // MARK: - Properties
    let duration: Double
    @State private var blinking = false
    
    // MARK: UI
    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0.5 : 1)
            .animation(.easeOut(duration: duration).repeatForever(), value: blinking)
            .onAppear {
                blinking = true
            }
    }
    
}
