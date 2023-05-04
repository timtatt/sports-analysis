//
//  Color.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//

import Foundation
import AppKit

struct ProjectCodeColor : Codable, Hashable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    static var white: ProjectCodeColor {
        get {
            ProjectCodeColor(nsColor: .white)
        }
    }
    
    var nsColor : NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(nsColor : NSColor) {
        nsColor.usingColorSpace(.sRGB)?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
