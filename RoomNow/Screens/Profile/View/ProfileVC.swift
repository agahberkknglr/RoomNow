//
//  ProfileVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class ProfileVC: UIViewController {

    private let viewModel: ProfileVMProtocol

    init(viewModel: ProfileVMProtocol = ProfileVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "hotelph") // Placeholder icon
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .appAccent
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .appSecondaryBackground
        return iv
    }()

    private let usernameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .appSecondaryBackground
        tf.isUserInteractionEnabled = false
        return tf
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .appSecondaryBackground
        tf.isUserInteractionEnabled = false
        return tf
    }()

    private let dobField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Date of Birth"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .appSecondaryBackground
        tf.isUserInteractionEnabled = false
        return tf
    }()

    private let genderPicker: UISegmentedControl = {
        let sg = UISegmentedControl(items: ["Male", "Female", "Other"])
        sg.selectedSegmentIndex = 0
        sg.setTitleTextAttributes([.foregroundColor: UIColor.appSecondaryText], for: .normal)
        sg.setTitleTextAttributes([.foregroundColor: UIColor.appAccent], for: .selected)
        sg.backgroundColor = .appSecondaryBackground
        sg.selectedSegmentTintColor = .appButtonBackground
        sg.isUserInteractionEnabled = false
        return sg
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        setNavigation(title: "Profile")
        
        logoutButton.applyLogOutStyle()

        let stack = UIStackView(arrangedSubviews: [
            usernameField,
            emailField,
            dobField,
            genderPicker,
            logoutButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImageView)
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 150),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            
            stack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func bindViewModel() {
        viewModel.fetchUser { [weak self] in
            DispatchQueue.main.async {
                guard let self = self, let user = self.viewModel.user else { return }
                self.usernameField.text = user.username
                self.emailField.text = user.email
                self.dobField.text = user.dateOfBirth
                self.genderPicker.selectedSegmentIndex = {
                    switch user.gender.lowercased() {
                    case "male": return 0
                    case "female": return 1
                    default: return 2
                    }
                }()
            }
        }
    }

    @objc private func logoutTapped() {
        viewModel.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Logged out")
                    if let tabBarVC = self?.tabBarController as? TabBarVC {
                        tabBarVC.reloadTabsAfterLogout()
                        tabBarVC.selectedIndex = 3
                    }
                case .failure(let error):
                    print("❌ Logout failed:", error.localizedDescription)
                }
            }
        }
    }
}
