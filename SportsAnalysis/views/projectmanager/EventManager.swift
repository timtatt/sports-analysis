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
    
    @State private var selectedEvents = Dictionary<UUID, ProjectEvent>()
    
    var body : some View {
        var _selectedEvent: ProjectEvent?
        let selectedEvent = Binding<UUID?>(
            get: { _selectedEvent?.id },
            set: { val in _selectedEvent = val != nil ? selectedEvents[val!] ?? nil : nil }
        )
        
        VStack {
            Text("Event Manager")
            List(project.events, selection: selectedEvent) { event in
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
            Text("\(TimeFormatter.toTimecode(seconds: event.startTime)): \(event.code.name) (\(TimeFormatter.toGeotime(seconds: event.duration)))")
//                    Button("x") {
//                        project.events.remove(at: index)
//                    }
        }
    }
}


struct EventManager_Previews: PreviewProvider {
    static var previews: some View {
        EventManager(project: Project())
    }
}
