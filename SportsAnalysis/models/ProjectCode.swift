//
//  File.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//
import Foundation
import AppKit
import SwiftUI

struct ProjectCode : Codable, Hashable {
    var id: UUID
    var name: String
    var colorName: String
    
    var shortcut: String
    var leadingTime: Float = 10
    var trailingTime: Float = 10
    
    static let availableColors: Set = [
        "Red",
        "Orange",
        "Yellow",
        "Green",
        "Aqua",
        "Blue",
        "Purple",
        "Pink"
    ]
    
    var color: Color {
        ProjectCode.availableColors.contains(colorName) ? Color(colorName) : Color("Blue")
    }
    
    var keyboardShortcut: KeyEquivalent {
        KeyEquivalent(Character(shortcut))
    }
    
    init(name: String, colorName: String = "Blue", shortcut: String = "") {
        self.id = UUID()
        self.name = name
        self.colorName = colorName
        self.shortcut = shortcut
    }
    
}
