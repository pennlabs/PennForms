@resultBuilder
public struct FormBuilder {
    public static func buildPartialBlock<Content: FormComponent>(first: Content) -> Content {
        first
    }
    
    public static func buildPartialBlock<C0: FormComponent, C1: FormComponent>(accumulated: C0, next: C1) -> _SequenceFormComponent<C0, C1> {
        return _SequenceFormComponent(c0: accumulated, c1: next)
    }
}
