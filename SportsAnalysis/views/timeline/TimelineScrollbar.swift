//
//  TimelineScrollbar.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 10/5/2023.
//

import Foundation
import SwiftUI
import AppKit
import CursorKit

struct TimelineScrollbar : View {
    
    @Binding var scrollPosition: CGFloat
    @Binding var zoomLevel: Float
    
    var maxZoomLevel: CGFloat
    var minZoomLevel: CGFloat
    var scrollRatio: CGFloat {
        self.minZoomLevel / CGFloat(self.zoomLevel)
    }
    
    var body : some View {
        GeometryReader { geometry in
            
            var minOverlayWidth: CGFloat {
                geometry.size.width * minZoomLevel / maxZoomLevel
            }
            
            let overlayStart: Binding<CGFloat> = Binding(
                get: { self.scrollRatio * self.scrollPosition },
                set: { val in scrollPosition = val / self.scrollRatio }
            )
            
            let overlayWidth: Binding<CGFloat> = Binding(
                get: { self.scrollRatio * geometry.size.width },
                set: { val in
                    zoomLevel = Float(geometry.size.width * minZoomLevel / val)
                }
            )
        
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
                
                TimelineScrollbarOverlay(minOverlayWidth: minOverlayWidth, overlayWidth: overlayWidth, overlayStart: overlayStart )
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(height: 20)
    }
}


struct TimelineScrollbarOverlay : View {
    
    let handleWidth: CGFloat = 4
    var minOverlayWidth: CGFloat
    
    @Binding var overlayWidth: CGFloat
    @Binding var overlayStart: CGFloat
    
    @State var startHandleHovering: Bool = false
    @State var endHandleHovering: Bool = false
    @State var overlayHovering: Bool = false
    
    @State var startingPoint: CGFloat = 0
    @State var startingWidth: CGFloat = 0
    @State var isDragging: Bool = false
    
    var body : some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.white).opacity(overlayHovering ? 0.6 : 0.4))
                    .frame(width: max(0, overlayWidth - handleWidth * 2), height: max(0, geometry.size.height))
                    .offset(x: overlayStart + handleWidth)
                    .cursor(.openHand)
                    .onHover { isHovering in overlayHovering = isHovering}
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingPoint = overlayStart
                                NSCursor.closedHand.push()
                            }
                            overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: geometry.size.width - overlayWidth)
                            
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
                                startingWidth = overlayWidth
                            }
                            overlayStart = BoundsChecker.minmax(minBound: 0, value: startingPoint + gesture.translation.width, maxBound: overlayStart + overlayWidth - minOverlayWidth)
                            overlayWidth = BoundsChecker.minmax(minBound: minOverlayWidth, value: startingWidth - gesture.translation.width, maxBound: geometry.size.width - startingWidth - startingPoint)
                        }
                        .onEnded { _ in isDragging = false}
                    )
                    .cursor(.resizeLeftRight)
                    .onHover { isHovering in
                        startHandleHovering = isHovering
                    }
                
                

                Rectangle()
                    .fill(Color(.white).opacity(endHandleHovering ? 1 : 0.8))
                    .cornerRadius(2, corners: [.topRight, .bottomRight])
                    .frame(width: handleWidth)
                    .offset(x: overlayStart + overlayWidth - handleWidth)
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if (!isDragging) {
                                isDragging = true
                                startingWidth = overlayWidth
                            }
                            overlayWidth = BoundsChecker.minmax(minBound: minOverlayWidth, value: startingWidth + gesture.translation.width, maxBound: geometry.size.width - overlayStart)
                        }
                        .onEnded { _ in isDragging = false}
                    )
                    .cursor(.resizeLeftRight)
                    .onHover { isHovering in
                        endHandleHovering = isHovering
                    }
            }
            
        }
    }
}


struct TimelineScrollbar_Preview : PreviewProvider {
    
    static var previews: some View {
        TimelineScrollbar(scrollPosition: .constant(200), zoomLevel: .constant(1), maxZoomLevel: 12, minZoomLevel: 1)
            .frame(width: 800)
    }
}
