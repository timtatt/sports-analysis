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
    
    var body : some View {
        ZStack {
            GeometryReader { geometry in
                // TODO unable to handle two events in the same space
                ForEach(getEventsInView(), id: \.id) { event in
                    EventBarItem(event: event, zoomLevel: zoomLevel)
                }
            }
            
        }
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .frame(height: 40)
    }
    
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
}

struct EventBarItem : View {
    
    @ObservedObject var event: ProjectEvent
    let zoomLevel: Float
    
    var body : some View {
        let eventStart = Binding<CGFloat>(
            get: { CGFloat(event.startTime * zoomLevel) },
            set: { val in
                let newStartTime = Float(val) / zoomLevel
                event.endTime = event.duration + newStartTime
                event.startTime = newStartTime
            }
        )
        let eventDuration = Binding<CGFloat>(
            get: {
                return CGFloat(event.duration * zoomLevel)
            },
            set: { val in
                let duration: Float = Float(val) / zoomLevel
                event.endTime = duration + event.startTime
            }
        )
        
        DraggableItem(
            overlayWidth: eventDuration,
            overlayStart: eventStart,
            minOverlayWidth: CGFloat(4 * zoomLevel),
            color: event.code.color,
            title: event.code.name)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
