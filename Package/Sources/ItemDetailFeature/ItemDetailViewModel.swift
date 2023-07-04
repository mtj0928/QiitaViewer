import Core
import Observation

@Observable
public final class ItemDetailViewModel {
    private(set) var downloadedItem = false

    @ObservationIgnored
    let item: Item

    @ObservationIgnored
    private let useCase: ItemDetailUseCase

    public init(
        item: Item,
        useCase: ItemDetailUseCase
    ) {
        self.item = item
        self.useCase = useCase
        downloadedItem = (try? useCase.hasItem(id: item.id)) ?? false
    }

    public func save() async {
        try? await useCase.save(item: item)
        downloadedItem = (try? useCase.hasItem(id: item.id)) ?? false
    }

    public func delete() async {
        try? await useCase.delete(itemID: item.id)
        downloadedItem = (try? useCase.hasItem(id: item.id)) ?? false
    }
}
