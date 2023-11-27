import SwiftUI

public struct PairFields<Content: View>: FormComponent {
    @ViewBuilder let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        HStack(alignment: .top) {
            content()
        }
    }
}
