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
            let events = project.events.values
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(events) { event in
                        switch (event.type) {
                        case .codedEvent:
                            EventListCodedEventItem(event: event as! ProjectCodedEvent)
                                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        case .marker:
                            let isFirst: Bool = events.first == event
                            EventListMarkerItem(isFirst: isFirst, event: event as! ProjectMarker)
                                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: -18, bottom: 0, trailing: 0))
            .scrollContentBackground(.hidden)
            
            
            Button("Export Selected Events") {
                print("not implemented")
            }
        }
    }
}

struct EventListCodedEventItem: View {
    var event: ProjectCodedEvent
    
    var body : some View {
        HStack(alignment: .center, spacing: 6) {
            Rectangle()
                .fill(event.code.color)
                .cornerRadius(4)
                .frame(width: 12, height: 30)
            
            Text("\(TimeFormatter.toTimecode(seconds: event.startTime)) (\(TimeFormatter.toGeotime(seconds: event.duration)))")
                .font(.system(size: 18))
                .frame(minWidth: 120, alignment: .leading)
            
            Text("\(event.code.name) ")
                .font(.system(size: 18))
                .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
            Spacer()
            
            Button(action: {
                print("play event")
            }) {
                Image(systemName: "play.fill")
                    .padding(7)
                    .font(.system(size: 18))
                    .background(Color("Primary"))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                print("delete event")
            }) {
                Image(systemName: "minus")
                    .frame(width: 20, height: 20)
                    .font(.system(size: 14))
                    .background(.red)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct EventListMarkerItem : View {
    var isFirst: Bool
    var event: ProjectMarker
    
    var body : some View {
        VStack(alignment: .leading, spacing: 0) {
            if (!isFirst) {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(.white)
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 12, trailing: 0))
            }
            HStack(alignment: .center, spacing: 6) {
                Text("\(TimeFormatter.toTimecode(seconds: event.startTime))")
                    .font(.system(size: 18))
                    .frame(minWidth: 120, alignment: .leading)
                
                Text("\(event.title)")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 0))
            }
        }
        .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 0))
    }
}


struct EventManager_Previews: PreviewProvider {
    static var previews: some View {
        let project: Project = {
            let project = Project()
            let code = ProjectCode(name: "Some Code")
            project.events[UUID()] = ProjectMarker(title: "Some Marker", startTime: 5)
            project.events[UUID()] = ProjectCodedEvent(code: code, startTime: 10, endTime: 23)
            project.events[UUID()] = ProjectCodedEvent(code: code, startTime: 12, endTime: 23)
            project.events[UUID()] = ProjectMarker(title: "Some Marker 2", startTime: 15)
            return project
        }()
        EventManager(project: project, playerState: PlayerState())
    }
}
