import SwiftUI

public protocol FormComponent: View {}

public struct _SequenceFormComponent<C0: FormComponent, C1: FormComponent>: FormComponent {
    let c0: C0
    let c1: C1
    
    public var body: some View {
        VStack(alignment: .leading) {
            c0
            c1
        }
    }
}

struct ComponentWrapper<Content: View>: FormComponent {
    @ViewBuilder let content: () -> Content
    
    init(content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()
    }
}
