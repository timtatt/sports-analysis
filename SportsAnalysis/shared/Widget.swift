//
//  Widget.swift
//  SportsAnalysis
//
//  Created by Tim Tattersall on 17/5/2023.
//

import Foundation
import SwiftUI

typealias WidgetActions<V> = Group<V> where V:View
typealias WidgetContent<V> = Group<V> where V:View

struct Widget<V1 : View, V2 : View> : View {
    typealias Content = TupleView<(WidgetActions<V1>, WidgetContent<V2>)>
    
    let content: () -> Content
    let title: String
    let icon: String?

    init(icon: String?, title: String, @ViewBuilder _ content: @escaping () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content
    }
    
    init(icon: String?, title: String, @ViewBuilder _ content: @escaping () -> V2) where V1 == EmptyView {
        self.icon = icon
        self.title = title
        self.content = {
            TupleView((
                WidgetActions {
                    EmptyView()
                },
                WidgetContent {
                    content()
                }
            ))
        }
    }
    
    var body : some View {
        GeometryReader { geometry in
            let (actions, body) = self.content().value
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    if (icon != nil) {
                        Image(systemName: icon!)
                            .font(.system(size: 20))
                    }
                    Text(title)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    actions
                        .frame(alignment: .trailing)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                body
            }
            .padding(10)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .background(Color("WidgetBackground"))
            .cornerRadius(8)
        }
    }
}


struct Widget_Preview : PreviewProvider {
    static var previews: some View {
        VStack {
            Widget(icon: "tag", title: "My Widget") {
                Text("some content")
            }
            .frame(width: 300)
            
            Widget(icon: "tag.fill", title: "My Widget") {
                WidgetContent {
                    Group {
                        Text("some content")
                    }
                }
            }
            .frame(width: 300)
        }
    }
}
