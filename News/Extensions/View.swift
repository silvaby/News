//
//  View.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import SwiftUI

extension View {
    
    func blinking(duration: Double = 0.3) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
    
}
