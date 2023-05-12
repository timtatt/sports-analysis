//
//  TimelineScrollbar.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 10/5/2023.
//

import Foundation
import SwiftUI
import AppKit

struct TimelineScrollbar : View {
    
    @Binding var overlayStart: CGFloat;
    
    @State var scrollbarWidth: CGFloat = 0;
    @State var overlayEnd: CGFloat = 400;
    @State var viewableWidth: CGFloat = 200;
    
    @State var overlayCursorOffset: CGFloat = 0;
    
    @State var isDragging: Bool = false
    @State var mouseDraggingOffset: CGFloat = 0
    
    var body : some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.purple)
                
                Circle()
                    .fill(.red)
                    .offset(x: 20)
                    .frame(width: 6, height: 6)
                
                Circle()
                    .fill(.blue)
                    .offset(x: 22)
                    .frame(width: 6, height: 6)
                
                TimelineScrollbarOverlay(overlayEnd: $overlayEnd, overlayStart: $overlayStart)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .coordinateSpace(name: "timelineScrollbarOverlay")
            }
            .onAppear {
                scrollbarWidth = geometry.size.width
            }
        }
        .coordinateSpace(name: "timelineScrollbar")
        .frame(height: 20)
    }
}


struct TimelineScrollbarOverlay : View {
    
    let handleWidth: CGFloat = 4
    
    @Binding var overlayEnd: CGFloat
    @Binding var overlayStart: CGFloat
    
    @State var startHandleHovering: Bool = false
    @State var endHandleHovering: Bool = false
    
    @State var startingPoint: CGFloat = 0
    @State var isDragging: Bool = false
    
    var body : some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.white).opacity(0.4))
                    .frame(width: overlayEnd - overlayStart - handleWidth * 2, height: geometry.size.height)
                    .offset(x: overlayStart + handleWidth)
                    .onHover { isHovering in
                        if isHovering {
                            NSCursor.openHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingPoint = overlayStart
                                NSCursor.closedHand.push()
                            }
                            let overlayWidth = overlayEnd - overlayStart
                            overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: geometry.size.width - overlayWidth)
                            overlayEnd = overlayStart + overlayWidth
                            
                        }
                        .onEnded { _ in
                            isDragging = false
                            NSCursor.pop()
                        }
                    )
                
                Rectangle()
                    .fill(Color(.white).opacity(startHandleHovering ? 1 : 0.8))
                    .cornerRadius(2, corners: [.topLeft, .bottomLeft])
                    .frame(width: handleWidth)
                    .offset(x: overlayStart)
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingPoint = overlayStart
                            }
                            overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: overlayEnd - 1)
                        }
                        .onEnded { _ in isDragging = false}
                    )
                    .onHover { isHovering in
                        startHandleHovering = isHovering
                        if (isHovering) {
                            NSCursor.resizeLeft.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                
                

                Rectangle()
                    .fill(Color(.white).opacity(endHandleHovering ? 1 : 0.8))
                    .cornerRadius(2, corners: [.topRight, .bottomRight])
                    .frame(width: handleWidth)
                    .offset(x: overlayEnd - handleWidth)
                    .onAppear {
                        print(endHandleHovering)
                    }
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingPoint = overlayEnd
                            }
                            overlayEnd = BoundsChecker.minmax(minBound: overlayStart + 1, value: startingPoint + gesture.translation.width, maxBound: geometry.size.width)
                        }
                        .onEnded { _ in isDragging = false}
                    )
                    .onHover { isHovering in
                        endHandleHovering = isHovering
                        if isHovering {
                            NSCursor.resizeRight.set()
                        } else {
                            NSCursor.pop()
                        }
                    }
            }
            
        }
    }
}


struct TimelineScrollbar_Preview : PreviewProvider {
    
    static var previews: some View {
        TimelineScrollbar(overlayStart: .constant(200))
            .frame(width: 800)
    }
}
