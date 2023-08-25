import SwiftUI
import UIKit

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
            Text("Dependency is not set.")
                .foregroundColor(.white)
                .font(.system(.title3, weight: .black))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red)
                .ignoresSafeArea()
#else
            EmptyView()
#endif
        }
    }
}

public enum UIDependencyProvider {
    public static func makeViewController(for view: UIView, factory: (Dependency) -> some UIViewController) -> UIViewController {
        if let dependency = view.traitCollection.dependency {
            factory(dependency)
        } else {
            UIHostingController(rootView: Text("Dependency is not set.")
                .foregroundColor(.white)
                .font(.system(.title3, weight: .black))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red)
                .ignoresSafeArea()
            )
        }
    }
}

private enum DependencyKey: EnvironmentKey, UITraitBridgedEnvironmentKey {
    static let defaultValue: Dependency? = nil

    static func read(from traitCollection: UITraitCollection) -> Dependency? {
        traitCollection.dependency
    }

    static func write(to mutableTraits: inout UIMutableTraits, value: Dependency?) {
        mutableTraits.dependency = value
    }
}

extension EnvironmentValues {
    public var dependency: Dependency? {
        get { self[DependencyKey.self] }
        set { self[DependencyKey.self] = newValue }
    }
}

private struct DependencyTrait: UITraitDefinition {
    static let defaultValue: Dependency? = nil
}

extension UITraitCollection {
    public var dependency: Dependency? { self[DependencyTrait.self] }
}

extension UIMutableTraits {
    public var dependency: Dependency? {
        get { self[DependencyTrait.self] }
        set { self[DependencyTrait.self] = newValue }
    }
}

#Preview {
    DependencyProvider { dependency in
        Text("Foo")
    }
}
