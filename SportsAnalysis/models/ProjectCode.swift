//
//  File.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 28/4/2023.
//
import Foundation
import AppKit

struct ProjectCode : Codable, Hashable {
    var name: String
    var color: Color
    
    // TODO change type at some point
    var shortcut: String
    var leadingTime: Double = 10
    var trailingTime: Double = 10
    
    init(name: String, color: Color = .white, shortcut: String) {
        self.name = name
        self.color = color
        self.shortcut = shortcut
    }
}
