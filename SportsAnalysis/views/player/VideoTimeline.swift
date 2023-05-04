//
//  VideoTimeline.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 3/5/2023.
//

import Foundation
import SwiftUI

struct Tick : Hashable {
    let time: Float
    let offset: CGFloat
    let majorTick: Bool
    
    var timecode: String {
        TimeFormatter.toTimecode(seconds: time)
    }
}

struct VideoTimeline : View {
    let fps = 24
    
    @ObservedObject var playerState: PlayerState
    
    let tickWidth: Int = 12
    let secondsPerTick: Float = 5
    let majorTick: Float = 60
    
    let videoDuration: Float = 4800
    
    @State var timelineOffset: Float = 21.5
    @State var zoomLevel: Int = 1
    
    @State var mouseLocation: NSPoint? = nil
    @State var isMouseOver: Bool = false
    
    func getTimelineWidth() -> CGFloat {
        return CGFloat(videoDuration / secondsPerTick * Float(tickWidth))
    }
    
    func getTicks(timelineWidth: CGFloat) -> [Tick] {
        var ticks: [Tick] = [
            Tick(
                time: secondsPerTick,
                offset: CGFloat(tickWidth),
                majorTick: false)
        ]
        
        repeat {
            let tickTime = ticks.last!.time + secondsPerTick
            ticks.append(Tick(
                time: tickTime,
                offset: ticks.last!.offset + CGFloat(tickWidth),
                majorTick: tickTime.remainder(dividingBy: majorTick) == 0))
        } while (ticks.last!.offset < timelineWidth)
        
        return ticks
    }
    
    var body : some View {
        GeometryReader { geometry in
            // Timeline
            ScrollView([.horizontal]) {
                ZStack(alignment: .bottomLeading) {
                    
                    VStack(spacing: 0) {
                        
                        // Timecode Bar
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(.green)
                            
                            // Timecode bar
                            GeometryReader { geometry in
                                ZStack(alignment: .bottomLeading) {
                                    Rectangle()
                                        .fill(.cyan)
                                    ForEach(getTicks(timelineWidth: geometry.size.width), id: \.self) { tick in
                                        Rectangle()
                                            .background(.gray)
                                            .frame(width: 1, height: tick.majorTick ? 10 : 5)
                                            .offset(x: tick.offset, y: 0)
                                        if (tick.majorTick) {
                                            Text(tick.timecode)
                                                .font(.system(size: 10))
                                                .position(x: tick.offset, y: -10)
                                        }
                                    }
                                }
                                .frame(width: geometry.size.width, height: 10, alignment: .bottomLeading)
                                .offset(y: 20)
                            }
                        }
                        .frame(height: 30, alignment: .bottom)
                        
                        // Event Bar
                        ZStack {
                            Rectangle()
                                .fill(.red)
                            Text("Event bar")
                        }
                        .frame(height: 40)
                    }
                    
                    // Cursor
                    if (isMouseOver && mouseLocation != nil) {
                        
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 1)
                            .offset(x: mouseLocation!.x, y: 0)
                    }
                    
                    // Scrubber
//                    Rectangle()
//                        .fill(.yellow)
//                        .frame(width: 1)
//                        .offset(x: CGFloat(playerState.playbackTime) * CGFloat(tickWidth), y: 0)
                }
                .frame(width: getTimelineWidth(), height: 66)
//                .onHover { on in isMouseOver = on }
                .onAppear {
//                    NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
//                        if (isMouseOver) {
//                            let frame = geometry.frame(in: .global)
//                            let mouseScreenLocation = NSApp.keyWindow?.mouseLocationOutsideOfEventStream ?? .zero
//
//                            mouseLocation = CGPoint(x: mouseScreenLocation.x - frame.origin.x, y: mouseScreenLocation.y - frame.origin.y)
//                        }
//                        return $0
//                    }
                }
            }
        }
    }
}

struct VideoTimeline_Previews : PreviewProvider {
    static var previews: some View {
        let state = PlayerState()
        HStack {
            VideoTimeline(playerState: state)
        }
        .onAppear {
            state.playbackTime = 11.2
        }
        .frame(width: 900, height: 80)
        
    }
}
