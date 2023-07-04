import SwiftData

extension ModelContainer {
    public static var mock: ModelContainer {
        try! ModelContainer(for: .default, configurations: [ModelConfiguration(inMemory: true)])
    }
}
extension Schema {
    public static var `default`: Schema {
        Schema([UserModel.self, ItemModel.self])
    }
}
