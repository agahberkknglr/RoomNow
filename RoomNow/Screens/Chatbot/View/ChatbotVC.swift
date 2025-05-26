//
//  ChatbotVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class ChatbotVC: UIViewController {
    
    private let tableView = UITableView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private var messages: [ChatMessage] = []
    private let viewModel = ChatbotVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Assistant"

        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        inputField.placeholder = "Type a message..."
        inputField.borderStyle = .roundedRect
        inputField.autocorrectionType = .no
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        let inputContainer = UIStackView(arrangedSubviews: [inputField, sendButton])
        inputContainer.axis = .horizontal
        inputContainer.spacing = 8
        inputContainer.translatesAutoresizingMaskIntoConstraints = false

        inputField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(inputContainer)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -8)
        ])
    }

    @objc private func sendTapped() {
        guard let text = inputField.text, !text.isEmpty else { return }
        
        appendMessage(text, sender: .user)
        inputField.text = ""
        viewModel.sendMessage(text)
    }

    private func appendMessage(_ text: String, sender: ChatSender) {
        messages.append(ChatMessage(sender: sender, text: text))
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
}

extension ChatbotVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var config = UIListContentConfiguration.valueCell()
        config.text = message.text
        config.textProperties.alignment = (message.sender == .user) ? .natural : .natural
        config.textProperties.color = (message.sender == .user) ? .label : .systemGray
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}

extension ChatbotVC: ChatbotVMDelegate {
    func didReceiveSearchData(_ data: ParsedSearchData) {
        let summary = """
        Destination: \(data.destination)
        Check-in: \(data.checkIn)
        Check-out: \(data.checkOut)
        Guests: \(data.guestCount)
        Rooms: \(data.roomCount)
        """
        appendMessage(summary, sender: .bot)

        // Optional: navigate to hotel results
    }

    func didFailWithError(_ error: Error) {
        appendMessage("⚠️ Error: \(error.localizedDescription)", sender: .bot)
    }
}
