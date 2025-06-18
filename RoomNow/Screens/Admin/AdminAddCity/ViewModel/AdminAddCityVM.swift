//
//  AdminAddCityVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.06.2025.
//

protocol AdminAddCityVMProtocol {
    var onSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    func addCity(named: String)
}

final class AdminAddCityVM: AdminAddCityVMProtocol {
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    func addCity(named rawName: String) {
        let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmed.isEmpty else {
            onError?("City name cannot be empty.")
            return
        }

        FirebaseManager.shared.addCityIfNotExists(name: trimmed) { [weak self] result in
            switch result {
            case .success:
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
}
