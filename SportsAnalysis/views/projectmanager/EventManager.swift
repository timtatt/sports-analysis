//
//  EventManager.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 27/4/2023.
//

import AppKit
import SwiftUI

struct EventManager : View {
    @ObservedObject var project : Project
    @ObservedObject var playerState : PlayerState
    
    @State private var selectedEvents = Dictionary<UUID, ProjectEvent>()
    
    
    var body : some View {
        var _selectedEvent: ProjectEvent?
        let selectedEvent = Binding<UUID?>(
            get: { _selectedEvent?.id },
            set: { val in
                _selectedEvent = val != nil ? project.events[val!] ?? nil : nil
                if (_selectedEvent != nil) {
                    playerState.seek(seconds: _selectedEvent!.startTime)
                    playerState.isPlaying = false
                }
            }
        )
        
        Widget(icon: "mappin.and.ellipse", title: "Events") {
            List(project.events.values, selection: selectedEvent) { event in
                EventListItem(event: event, selectedEvents: $selectedEvents)
            }
            Button("Export Selected Events") {
                print("not implemented")
            }
        }
    }
}

struct EventListItem : View {
    @ObservedObject var event: ProjectEvent
    @Binding var selectedEvents: Dictionary<UUID, ProjectEvent>
    
    
    var body : some View {
        let isSelected: Binding<Bool> = Binding(
            get: { selectedEvents[event.id] != nil },
            set: { (val: Bool) -> Void in
                if (val) {
                    selectedEvents[event.id] = event
                } else {
                    selectedEvents[event.id] = nil
                }
            }
        )
        
        HStack {
            Toggle("", isOn: isSelected)
                .toggleStyle(.checkbox)
            Circle()
                .fill(event.code.color)
                .frame(width: 20, height: 20)
            Text("\(TimeFormatter.toTimecode(seconds: event.startTime)): \(event.code.name) (\(TimeFormatter.toGeotime(seconds: event.duration)))")
//                    Button("x") {
//                        project.events.remove(at: index)
//                    }
        }
    }
}


struct EventManager_Previews: PreviewProvider {
    static var previews: some View {
        EventManager(project: Project(), playerState: PlayerState())
    }
}
