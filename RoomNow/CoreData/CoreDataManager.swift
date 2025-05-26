//
//  CoreDataManager.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 26.05.2025.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RoomNowDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data: \(error)")
            }
        }
    }
}

extension CoreDataManager {
    func saveRecentSearch(_ parameters: HotelSearchParameters, for userId: String) {
        let context = context

        let fetchRequest: NSFetchRequest<RecentSearch> = RecentSearch.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@ AND destination == %@ AND checkInDate == %@ AND checkOutDate == %@ AND guestCount == %d AND roomCount == %d", userId, parameters.destination, parameters.checkInDate as CVarArg, parameters.checkOutDate as CVarArg, parameters.guestCount, parameters.roomCount)

        if let results = try? context.fetch(fetchRequest), let duplicate = results.first {
            context.delete(duplicate)
        }

        let newSearch = RecentSearch(context: context)
        newSearch.userId = userId
        newSearch.destination = parameters.destination
        newSearch.checkInDate = parameters.checkInDate
        newSearch.checkOutDate = parameters.checkOutDate
        newSearch.guestCount = Int16(parameters.guestCount)
        newSearch.roomCount = Int16(parameters.roomCount)
        newSearch.timestamp = Date()

        saveContext()
    }

    func fetchRecentSearches(for userId: String) -> [RecentSearch] {
        let request: NSFetchRequest<RecentSearch> = RecentSearch.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
    
    func deleteRecentSearch(_ search: RecentSearch) {
        context.delete(search)
        saveContext()
    }
}
