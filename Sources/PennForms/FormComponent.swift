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

public struct ComponentWrapper<Content: View>: FormComponent {
    @ViewBuilder let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }
    public var body: some View {
        content()
    }
}
