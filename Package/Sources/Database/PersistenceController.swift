import CoreData

extension NSPersistentContainer {
    public static var mock: NSPersistentContainer {
        make(inMemory: true)
    }


    public static func make(inMemory: Bool) -> NSPersistentContainer {
        let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
}
