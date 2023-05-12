//
//  Color.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation
import AppKit


// TODO convert this to an enum
struct ProjectCodeColor : Codable, Hashable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var nsColor : NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(_ nsColor : NSColor) {
        nsColor.usingColorSpace(.sRGB)?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
