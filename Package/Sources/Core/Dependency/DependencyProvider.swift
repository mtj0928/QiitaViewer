import SwiftUI

public struct DependencyProvider<Content>: View where Content: View {

    @Environment(\.dependency)
    var dependency

    private let content: (Dependency) -> Content

    public init(content: @escaping (Dependency) -> Content) {
        self.content = content
    }

    public var body: some View {
        if let dependency {
            content(dependency)
        } else {
#if DEBUG
            Rectangle()
                .foregroundColor(.red)
                .overlay {
                    Text("Dependency is not set.")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.black)
                }
                .ignoresSafeArea()
#else
            EmptyView()
#endif
        }
    }
}

extension EnvironmentValues {
    private enum Key: EnvironmentKey {
        static let defaultValue: Dependency? = nil
    }

    public var dependency: Dependency? {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }
}

