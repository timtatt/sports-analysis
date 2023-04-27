//
//  ProjectSettings.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import Foundation
import SwiftUI

struct ProjectSettingsView : View {
    @ObservedObject var project: Project
    
    
    var body : some View {
        TextField("Project Title", text: $project.name)
    }
}
