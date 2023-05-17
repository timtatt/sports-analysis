//
//  TimelineScrubber.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 17/5/2023.
//

import Foundation
import SwiftUI

struct TimelineScrubber : View {
    
    let height: CGFloat
    
    var body : some View {
        VStack(alignment: .center, spacing: -2) {
            TimelineScrubberHandle()
                .fill(.blue)
                .frame(width: 12, height: 22)
            Rectangle()
                .fill(.blue)
                .frame(width: 1, height: height + 2)
        }
    }
}

struct TimelineScrubberHandle : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}

struct TimelineScrubber_Preview : PreviewProvider {
    
    static var previews: some View {
        TimelineScrubber(height: 60)
            
    }
}
