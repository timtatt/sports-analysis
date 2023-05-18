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
    var zoomLevel: Float
    var scrollOffset: CGFloat
    var timelineWrapperWidth: CGFloat
    
    var events: OrderedDictionary<UUID, ProjectEvent>
    
    func getEventsInView() -> [ProjectEvent] {
        let viewStartTime: Float = Float(scrollOffset) / zoomLevel;
        let viewEndTime: Float = viewStartTime + Float(timelineWrapperWidth) / zoomLevel;
        
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
                ForEach(getEventsInView(), id: \.id) { event in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(event.code.color)
                        .offset(x: CGFloat(event.startTime * zoomLevel), y: 2)
                        .frame(width: CGFloat(event.duration * zoomLevel), height: geometry.size.height - 4)
                }
            }
            
        }
        .frame(height: 40)
    }
}
