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
    
    @State var pixelsPerSecond: Float = 12
    
    @ObservedObject var playerState: PlayerState
    
    @State var mouseLocation: NSPoint? = nil
    @State var isMouseOver: Bool = false
    @State var scrollOffset: CGFloat = 0.0
    
    func getTimelineWidth() -> CGFloat {
        return CGFloat(playerState.duration * pixelsPerSecond)
    }
    
    func pixelsPerSecondScale(width: CGFloat) -> ClosedRange<Float> {
        let minPixelsPerSecond = Float(width) / playerState.duration
        
        return (minPixelsPerSecond > 24 ? 1 : minPixelsPerSecond)...24
    }
   
    
    var body : some View {
        GeometryReader { geometry in
            VStack {
                Slider(value: $pixelsPerSecond, in: pixelsPerSecondScale(width: geometry.size.width))
                ZStack {
                    GeometryReader { outerScrollGeometry in
                        TrackableScrollView([.horizontal], contentOffset: $scrollOffset) {
                            ZStack(alignment: .bottomLeading) {
                                
                                VStack(spacing: 0) {
                                    
                                    
                                    // Timecode Bar
                                    TimecodeBar(videoDuration: playerState.duration, pixelsPerSecond: pixelsPerSecond, scrollOffset: scrollOffset, timelineWrapperWidth: outerScrollGeometry.size.width)
                                    
                                    // Event Bar
                                    ZStack {
                                        Rectangle()
                                            .fill(.red)
                                        Text("Event bar")
                                    }
                                    .frame(height: 40)
                                }
                                
                                // Scrubber
                                Rectangle()
                                    .fill(.yellow)
                                    .frame(width: 1)
                                    .offset(x: CGFloat(playerState.playbackTime * pixelsPerSecond), y: 0)
                            }
                            .onTapGesture {
                                let offsetPosition = scrollOffset + mouseLocation!.x
                                let playbackPosition = offsetPosition / CGFloat(pixelsPerSecond)
                                playerState.seek(seconds: Float(playbackPosition))
                            }
                            .frame(width: getTimelineWidth(), height: outerScrollGeometry.size.height)
                        }
                        if (mouseLocation != nil) {
                            Rectangle()
                                .fill(.gray)
                                .frame(width: 1)
                                .allowsHitTesting(false)
                                .offset(x: mouseLocation!.x, y: 0)
                        }
                    }
                }
                .frame(height: 66)
                .onHover { on in
                    isMouseOver = on
                    if (!on) {
                        mouseLocation = nil
                    }
                    
                }
                .onAppear {
                    NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                        if (isMouseOver) {
                            let frame = geometry.frame(in: .global)
                            let mouseScreenLocation = NSApp.keyWindow?.mouseLocationOutsideOfEventStream ?? .zero
                            
                            mouseLocation = CGPoint(x: mouseScreenLocation.x - frame.origin.x, y: mouseScreenLocation.y - frame.origin.y)
                        }
                        return $0
                    }
                }
            }
        }
    }
}

struct TickSetting {
    let minorTickSeconds: Float
    let majorTickSeconds: Float
}

struct TimecodeBar : View {
    var videoDuration: Float
    var pixelsPerSecond: Float
    var scrollOffset: CGFloat
    var timelineWrapperWidth: CGFloat
    
    var timelineOffset : Float {
        let scrollOffsetWithLowerLimit = max(0, Float(scrollOffset))
        
        let timelineOffset = scrollOffsetWithLowerLimit / pixelsPerSecond
        let timelineWrapperWidthSeconds = Float(timelineWrapperWidth) / pixelsPerSecond
        
        // TODO calculate upper bound to prevent the ticks from overflowing
        return min(videoDuration - timelineWrapperWidthSeconds, timelineOffset)
    }
    
    let tickSettings = [
        TickSetting(minorTickSeconds: 1, majorTickSeconds: 5),
        TickSetting(minorTickSeconds: 2, majorTickSeconds: 10),
        TickSetting(minorTickSeconds: 10, majorTickSeconds: 30),
        TickSetting(minorTickSeconds: 5, majorTickSeconds: 60),
        TickSetting(minorTickSeconds: 10, majorTickSeconds: 60),
        TickSetting(minorTickSeconds: 15, majorTickSeconds: 60),
        TickSetting(minorTickSeconds: 30, majorTickSeconds: 300),
        TickSetting(minorTickSeconds: 60, majorTickSeconds: 300),
        TickSetting(minorTickSeconds: 60, majorTickSeconds: 600),
        TickSetting(minorTickSeconds: 120, majorTickSeconds: 600),
        TickSetting(minorTickSeconds: 300, majorTickSeconds: 3600),
        TickSetting(minorTickSeconds: 600, majorTickSeconds: 3600),
    ]
    
    
    func bestTickSetting() -> TickSetting {
        var tickSetting = tickSettings.first!
        
        for setting in tickSettings {
            tickSetting = setting
            let tickWidth = pixelsPerSecond * Float(setting.minorTickSeconds)
            if (tickWidth > 12) {
                break
            }
        }
        
        return tickSetting
    }
    
    
    func getTicks() -> [Tick] {
        let tickSetting = bestTickSetting()
        
        let tickWidth = pixelsPerSecond * Float(tickSetting.minorTickSeconds)
        
        let nextTickTime = ceil(timelineOffset / tickSetting.minorTickSeconds) * tickSetting.minorTickSeconds
        let nextTickOffset = nextTickTime * pixelsPerSecond
        
        var ticks: [Tick] = [
            Tick(
                time: nextTickTime,
                offset: CGFloat(nextTickOffset),
                majorTick: false)
        ]
        
        repeat {
            let tickTime = ticks.last!.time + tickSetting.minorTickSeconds
            ticks.append(Tick(
                time: tickTime,
                offset: ticks.last!.offset + CGFloat(tickWidth),
                majorTick: tickTime.remainder(dividingBy: tickSetting.majorTickSeconds) == 0))
        } while (ticks.last!.offset < timelineWrapperWidth + scrollOffset)
        
        return ticks
    }
    
    var body : some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.green)
                    
            // todo use canvas for timecode bar performance
            GeometryReader { geometry in
                
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(.cyan)
                    ForEach(getTicks(), id: \.self) { tick in
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
