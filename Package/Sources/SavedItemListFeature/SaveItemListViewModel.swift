import Core
import CoreData
import Database
import Observation

@Observable
public final class SaveItemListViewModel {
    let container: NSPersistentContainer
    let observer: FetchedResultsObserver

    var items: [Item] {
        observer.items.map { model in
            Item(model)
        }
    }

    public init(container: NSPersistentContainer) {
        self.container = container

        let fetchRequest = ItemModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ItemModel.insertedAt, ascending: true)]
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        observer = FetchedResultsObserver(fetchedResultController: fetchedResultController)
    }
}

@Observable
final class FetchedResultsObserver: NSObject, NSFetchedResultsControllerDelegate {
    var items: [ItemModel] = []
    private let fetchedResultController: NSFetchedResultsController<ItemModel>

    init(fetchedResultController: NSFetchedResultsController<ItemModel>) {
        self.fetchedResultController = fetchedResultController
        super.init()

        fetchedResultController.delegate = self
        try! fetchedResultController.performFetch()
        items = fetchedResultController.fetchedObjects ?? []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        items = controller.fetchedObjects?.compactMap { $0 as? ItemModel } ?? []
    }
}
