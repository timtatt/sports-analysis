//
//  EventBar.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 10/5/2023.
//

import Foundation
import SwiftUI
import OrderedCollections

struct EventBar : View {
    var videoDuration: Float
    var pixelsPerSecond: Float
    var scrollOffset: CGFloat
    var timelineWrapperWidth: CGFloat
    
    var events: OrderedDictionary<UUID, ProjectEvent>
    
    func getEventsInView() -> [ProjectEvent] {
        let viewStartTime: Float = Float(scrollOffset) / pixelsPerSecond;
        let viewEndTime: Float = viewStartTime + Float(timelineWrapperWidth) / pixelsPerSecond;
        
        var eventsInView: [ProjectEvent] = []
        
        for event in events.values {
            if (event.endTime >= viewStartTime || event.startTime < viewEndTime) {
                eventsInView.append(event)
            }
        }
        
        return eventsInView
    }
    
    var body : some View {
        ZStack {
            GeometryReader { geometry in
                Rectangle()
                    .fill(.red)
                ForEach(getEventsInView(), id: \.id) { event in
                    Rectangle()
                        .fill(Color(event.code.color.nsColor))
                        .offset(x: CGFloat(event.startTime * pixelsPerSecond))
                        .frame(width: CGFloat(event.duration * pixelsPerSecond), height: geometry.size.height)
                }
            }
            
        }
        .frame(height: 40)
    }
}
