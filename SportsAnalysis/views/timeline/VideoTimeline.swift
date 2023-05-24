//
//  VideoTimeline.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 3/5/2023.
//

import Foundation
import SwiftUI
import OrderedCollections
import AVKit

struct VideoTimeline : View {
    
    let maxZoomLevel: Float = 18
    
    @ObservedObject var project: Project
    @ObservedObject var playerState: PlayerState
    
    
    var timelineWidth: CGFloat {
        CGFloat(playerState.duration * zoomLevel)
    }
    
    @State var scrollPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State var zoomLevel: Float = 12
    
    @State var isZooming: Bool = false
    @State var startingZoomLevel: Float = 0
    @State var startingScrubberPosition: Float = 0
        
    var body : some View {
        GeometryReader { geometry in
            var minZoomLevel : CGFloat {
                geometry.size.width / CGFloat(playerState.duration)
            }
            var zoomLevelScale: ClosedRange<Float> {
                let minZoomLevel = Float(minZoomLevel)
                return (minZoomLevel > 24 ? 1 : minZoomLevel)...maxZoomLevel
            }
            
            VStack {
                TrackableScrollView(scrollPosition: $scrollPosition, backgroundColor: NSColor(Color("WidgetBackground"))) {
                    ZStack(alignment: .bottomLeading) {
                        VStack(spacing: 0) {
                            TimecodeBar(
                                videoDuration: playerState.duration,
                                zoomLevel: zoomLevel,
                                scrollOffset: scrollPosition.x,
                                timelineWrapperWidth: geometry.size.width)
                            .onTapGesture {
                                let offsetPosition = scrollPosition.x + getMouseLocation(geometry).x
                                let playbackPosition = offsetPosition / CGFloat(zoomLevel)
                                playerState.seek(seconds: Float(playbackPosition))
                            }
                            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
                                .onChanged { gesture in
                                    let mouseLocation = getMouseLocation(geometry)
                                    let offsetPosition = scrollPosition.x + mouseLocation.x
                                    let playbackPosition = BoundsChecker.minmax(minBound: 0, value: Float(offsetPosition) / zoomLevel, maxBound: playerState.duration)
      
                                    // Autoscroll when dragging the 
                                    if (mouseLocation.x > geometry.size.width) {
                                        scrollPosition.x = BoundsChecker.minmax(minBound: 0, value: scrollPosition.x + mouseLocation.x - geometry.size.width, maxBound: timelineWidth - geometry.size.width)
                                    } else if (mouseLocation.x < 0) {
                                        scrollPosition.x = BoundsChecker.minmax(minBound: 0, value: scrollPosition.x + mouseLocation.x, maxBound: timelineWidth - geometry.size.width)
                                    }
                                    
                                    if (!playerState.isScrubbing) {
                                        NSCursor.closedHand.push()
                                        playerState.startScrubbing()
                                    }
                                    
                                    playerState.playbackTime = BoundsChecker.minmax(minBound: 0, value: playbackPosition, maxBound: playerState.duration)
                                }
                                .onEnded { _ in
                                    playerState.stopScrubbing()
                                    NSCursor.pop()
                                })
                            
                            EventBar(
                                videoDuration: playerState.duration,
                                zoomLevel: zoomLevel,
                                scrollOffset: scrollPosition.x,
                                timelineWrapperWidth: geometry.size.width,
                                events: project.events)
                        }
                        
                        // TODO scrubber does weird things while zooming
                        TimelineScrubber(height: 40)
                            .cursor(.openHand)
                            .offset(x: CGFloat(playerState.playbackTime * zoomLevel) - 6, y: 0)
                            .gesture(DragGesture()
                                .onChanged { gesture in
                                    if (!playerState.isScrubbing) {
                                        NSCursor.closedHand.push()
                                        playerState.startScrubbing()
                                        startingScrubberPosition = playerState.playbackTime
                                    }
                                    playerState.playbackTime = BoundsChecker.minmax(minBound: 0, value: startingScrubberPosition + (Float(gesture.translation.width) / zoomLevel), maxBound: playerState.duration)
                                }
                                .onEnded { _ in
                                    playerState.stopScrubbing()
                                    NSCursor.pop()
                                })
                    }
                    .frame(maxHeight: .infinity)
                    .frame(width: timelineWidth)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .cornerRadius(8)
                .gesture(MagnificationGesture()
                    .onChanged { scale in
                        if (!isZooming) {
                            isZooming = true
                            startingZoomLevel = zoomLevel
                        }
                        let newZoomLevel = BoundsChecker.minmax(minBound: Float(minZoomLevel), value: startingZoomLevel * Float(scale.magnitude), maxBound: maxZoomLevel)
                        
                        let mouseLocation = getMouseLocation(geometry)
                        let newScrollPosition = (CGFloat(newZoomLevel) * (scrollPosition.x + mouseLocation.x) / CGFloat(zoomLevel)) - mouseLocation.x
                        
                        scrollPosition.x = BoundsChecker.minmax(minBound: 0, value: newScrollPosition, maxBound: CGFloat(playerState.duration * newZoomLevel) - geometry.size.width)
                        zoomLevel = newZoomLevel
                    }
                    .onEnded { _ in isZooming = false }
                )
                
                TimelineScrollbar(
                    scrollPosition: $scrollPosition.x,
                    zoomLevel: $zoomLevel,
                    events: project.events.values.elements,
                    maxZoomLevel: CGFloat(maxZoomLevel),
                    minZoomLevel: minZoomLevel
                )
            }
        }
    }
    
    func getMouseLocation(_ geometry: GeometryProxy) -> CGPoint {
        let frame = geometry.frame(in: .global)
        let mouseScreenLocation = NSApp.keyWindow?.mouseLocationOutsideOfEventStream ?? .zero
        return CGPoint(x: mouseScreenLocation.x - frame.origin.x, y: mouseScreenLocation.y - frame.origin.y)
    }
}

class MockAVPlayerItem : AVPlayerItem {
    public override var duration: CMTime {
        CMTime(value: 3000, timescale: 1)
    }
}

struct VideoTimeline_Previews : PreviewProvider {
    static var previews: some View {
        let state: PlayerState = {
            let state = PlayerState()
            let composition = AVMutableComposition()
            state.playerItem = MockAVPlayerItem(asset: composition)
            state.playbackTime = 11.2
            return state
        }()
        
        VStack {
            VideoTimeline(project: Project(), playerState: state)
        }
        .frame(width: 900, height: 160)
        
    }
}
