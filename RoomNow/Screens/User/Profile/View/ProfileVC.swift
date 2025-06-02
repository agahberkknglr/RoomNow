//
//  ProfileVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit
import PhotosUI

final class ProfileVC: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewModel: ProfileVMProtocol
    private var isEditingProfile = false
    private var editBarButton: UIBarButtonItem!

    init(viewModel: ProfileVMProtocol = ProfileVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUser()
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        title = "Profile"

        editBarButton = UIBarButtonItem(
            title: "Edit", style: .plain,
            target: self, action: #selector(editTapped)
        )
        navigationItem.rightBarButtonItem = editBarButton

        
        tableView.isHidden = true
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(type: ProfileImageCell.self)
        tableView.registerCell(type: TextFieldCell.self)
        tableView.registerCell(type: GenderPickerCell.self)
        tableView.registerCell(type: DateFieldCell.self)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func fetchUser() {
        showLoadingIndicator()
        viewModel.fetchUser { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.tableView.isHidden = false 
                self?.tableView.reloadData()            }
        }
    }

    @objc private func editTapped() {
        if isEditingProfile {
            saveProfileData()
            editBarButton.title = "Edit"
        } else {
            editBarButton.title = "Save"
            editBarButton.isEnabled = !(viewModel.user?.username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }

        isEditingProfile.toggle()
        tableView.reloadData()
    }
    
    private func saveProfileData() {
        guard var updatedUser = viewModel.user else { return }

        guard let usernameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TextFieldCell else { return }
        let username = usernameCell.getText().trimmingCharacters(in: .whitespacesAndNewlines)

        if username.isEmpty {
            showToast(message: "Please enter a valid name.")
            return
        }
        
        updatedUser.username = username

        if let genderCell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? GenderPickerCell {
            updatedUser.gender = genderCell.selectedGender()
        }

        if let dob = viewModel.user?.dateOfBirth {
            updatedUser.dateOfBirth = dob
        }
        
        updatedUser.profileImageBase64 = viewModel.user?.profileImageBase64

        viewModel.setUser(updatedUser)
        showLoadingIndicator()
        viewModel.updateUser(updatedUser) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                switch result {
                case .success:
                    self?.showToast(message: "Profile updated")
                case .failure(let error):
                    self?.showToast(message: "Update failed: \(error.localizedDescription)")
                }
                self?.tableView.reloadData()
            }
        }
    }
}

extension ProfileVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        6
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 5 ? 0 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = viewModel.user else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeue(ProfileImageCell.self, for: indexPath)
            cell.configure(with: user.profileImageBase64)
            cell.onTapImage = { [weak self] in
                guard self?.isEditingProfile == true else { return }
                self?.presentImagePicker()
            }
            return cell

        case 1:
            let cell = tableView.dequeue(TextFieldCell.self, for: indexPath)
            cell.configure(title: "Fullname", text: user.username, isEditable: isEditingProfile)

            cell.onTextChanged = { [weak self] text in
                let isValid = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                self?.editBarButton.isEnabled = isValid || !(self?.isEditingProfile ?? false)
            }
            return cell

        case 2:
            let cell = tableView.dequeue(TextFieldCell.self, for: indexPath)
            cell.configure(title: "Email", text: user.email, isEditable: false)
            return cell

        case 3:
            let cell = tableView.dequeue(GenderPickerCell.self, for: indexPath)
            cell.configure(selected: user.gender, isEnabled: isEditingProfile)
            return cell

        case 4:
            let cell = tableView.dequeue(DateFieldCell.self, for: indexPath)
            cell.configure(title: "Date of Birth", date: user.dateOfBirth, isEditable: isEditingProfile)
            cell.onDateChanged = { [weak self] updatedDOB in
                self?.viewModel.setDateOfBirth(updatedDOB)
            }
            return cell

        default:
            return UITableViewCell()
        }
    }
}


extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 5 ? 80 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 5 else { return nil }

        let footerView = UIView()
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        button.applyLogOutStyle()

        footerView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
             button.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 12),
             button.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -12),
             button.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
             button.heightAnchor.constraint(equalToConstant: 48)
         ])
        return footerView
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.logout { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        if let tabBarVC = self?.tabBarController as? TabBarVC {
                            tabBarVC.reloadTabsAfterLogout()
                            tabBarVC.selectedIndex = 3
                        }
                    case .failure(let error):
                        print("Logout failed:", error.localizedDescription)
                    }
                }
            }
        }))

        present(alert, animated: true)
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentImagePicker() {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.openImagePicker(sourceType: .camera)
        })

        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }

        if let base64 = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() {
            viewModel.setProfileImage(base64: base64)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
}

