//
//  TimelineScrollbar.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 10/5/2023.
//

import Foundation
import SwiftUI
import AppKit
import CursorKit

struct TimelineScrollbar : View {
    
    @Binding var scrollPosition: CGFloat
    @Binding var zoomLevel: Float
    
    var events: [ProjectEvent]
    
    var maxZoomLevel: CGFloat
    var minZoomLevel: CGFloat
    var scrollRatio: CGFloat {
        self.minZoomLevel / CGFloat(self.zoomLevel)
    }
    
    var body : some View {
        GeometryReader { geometry in
            
            var minOverlayWidth: CGFloat {
                geometry.size.width * minZoomLevel / maxZoomLevel
            }
            
            let overlayStart: Binding<CGFloat> = Binding(
                get: { self.scrollRatio * self.scrollPosition },
                set: { val in scrollPosition = val / self.scrollRatio }
            )
            
            let overlayWidth: Binding<CGFloat> = Binding(
                get: { min(geometry.size.width, self.scrollRatio * geometry.size.width) },
                set: { val in zoomLevel = Float(geometry.size.width * minZoomLevel / val) }
            )
        
            ZStack(alignment: .leading) {
                ForEach(events, id: \.id) { event in
                    Circle()
                        .fill(event.code.color)
                        .offset(x: CGFloat(event.startTime) * minZoomLevel)
                        .frame(width: 6, height: 6)
                }
                
                
                DraggableItem(
                    overlayWidth: overlayWidth,
                    overlayStart: overlayStart,
                    minOverlayWidth: minOverlayWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color("WidgetBackground"))
        }
        .cornerRadius(6)
        .frame(height: 20)
    }
}


struct TimelineScrollbar_Preview : PreviewProvider {
    
    static var previews: some View {
        TimelineScrollbar(scrollPosition: .constant(200), zoomLevel: .constant(1), events: [], maxZoomLevel: 12, minZoomLevel: 1)
            .frame(width: 800)
    }
}
