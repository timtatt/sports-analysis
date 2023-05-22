//
//  ProjectCodeItem.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 19/5/2023.
//

import Foundation
import SwiftUI
import CursorKit
import AppKit

struct ProjectCodeItem : View {
    
    let code: ProjectCode
    let addEventHandler: () -> Void
    
    @State var isHovering = false
    
    var body : some View {
        HStack {
            Button(action: addEventHandler) {
                Text(code.shortcut.uppercased())
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .frame(width: 34, height: 34)
                    .background(code.color)
                    .cornerRadius(6)
                
            }
            .buttonStyle(.plain)
            .keyboardShortcut(code.keyboardShortcut, modifiers: [])
            Text(code.name)
                .font(.system(size: 18))
            Spacer()
            Text("(20)")
                .font(.system(size: 18))
            Image(systemName: "chevron.right")
                .font(.system(size: 18))
        }
        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
        .background(Color("WidgetHover").opacity(isHovering ? 1 : 0))
        .cornerRadius(8)
        .onChange(of: isHovering) { val in
            DispatchQueue.main.async {
                if (val) {
                    Cursor.pointingHand.push()
                } else {
                    Cursor.pop()
                }
            }
        }
        .onHover { isHovering in self.isHovering = isHovering }
    }
}

struct ProjectCodeItem_Preview : PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            ProjectCodeItem(code: ProjectCode(name: "Some Code", colorName: "Blue", shortcut: "A"), addEventHandler: {})
        }
    }
}
