//
//  TrackableScrollView.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 8/5/2023.
//

import Foundation
import SwiftUI
import AppKit
import Combine

struct TrackableScrollView<Content : View> : NSViewRepresentable {
    
    @Binding var scrollPosition: CGPoint
    @ViewBuilder var content: () -> Content
    
    init(scrollPosition: Binding<CGPoint>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self._scrollPosition = scrollPosition
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let view = NSScrollView()
        // TODO add ability to chose axis
        
        view.hasVerticalScroller = false
        view.hasHorizontalScroller = true
        view.horizontalScrollElasticity = .none
        
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.viewScrolled(_:)), name: NSView.boundsDidChangeNotification, object: view.contentView)
        
        let hostingView = NSHostingView(rootView: content())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.documentView = hostingView
        return view
    }

    func updateNSView(_ view: NSScrollView, context: Context) {
        
        let hostingView = view.documentView as! NSHostingView<Content>
        hostingView.rootView = content()
        
        view.contentView.scroll(to: scrollPosition)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, scrollPosition: $scrollPosition)
    }
    
    class Coordinator {
        @Binding var scrollPosition: CGPoint
        var cachedScrollPosition: CGPoint? = nil
        
        let parent: TrackableScrollView
        
        init(_ parent: TrackableScrollView, scrollPosition: Binding<CGPoint>) {
            self.parent = parent
            self._scrollPosition = scrollPosition
        }
        
        @objc func viewScrolled(_ notification: NSNotification) {
            DispatchQueue.main.async {
                let contentView = notification.object as! NSView
                
                self.cachedScrollPosition = contentView.bounds.origin
                self.scrollPosition = contentView.bounds.origin
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
