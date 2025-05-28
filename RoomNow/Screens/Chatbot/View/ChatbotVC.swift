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
    private var lastParsedSearchData: ParsedSearchData?
    private let viewModel = ChatbotVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavBar()
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
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.allowsSelection = true
        tableView.isUserInteractionEnabled = true
        
        tableView.registerCell(type: ChatBubbleCell.self)
        tableView.registerCell(type: HotelChatCell.self)
        tableView.registerCell(type: SummaryChatCell.self)
        tableView.registerCell(type: RoomChatCell.self)

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
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped))
    }

    @objc private func cancelTapped() {
        let alert = UIAlertController(title: "Cancel Reservation", message: "This will reset the current chat flow. Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.viewModel.resetConversation()
            self.messages.removeAll()
            self.tableView.reloadData()
            self.appendMessage("🔄 Reservation flow reset. You can start again.", sender: .bot)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func sendTapped() {
        guard let text = inputField.text, !text.isEmpty else { return }
        appendMessage(text, sender: .user)
        inputField.text = ""
        viewModel.handleUserInput(text)
    }

    func appendMessage(_ text: String, sender: ChatSender, type: ChatMessageType = .text, payload: Any? = nil) {
        let shouldShowAvatar: Bool = {
            if let last = messages.last {
                return last.sender != sender
            }
            return true
        }()

        let message = ChatMessage(sender: sender, text: text, type: type, payload: payload, showAvatar: shouldShowAvatar)
        messages.append(message)

        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    func appendMessage(_ message: ChatMessage) {
        messages.append(message)
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
        switch message.type {
            
        case .text:
            let cell = tableView.dequeue(ChatBubbleCell.self, for: indexPath)
            cell.configure(with: message)
            return cell
            
        case .summary:
            guard let data = message.payload as? ParsedSearchData else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeue(SummaryChatCell.self, for: indexPath)
            cell.configure(with: data, showAvatar: message.showAvatar)
            
            cell.onSearchTapped = { [weak self] in
                guard let self = self else { return }
                if var last = self.messages.last, last.type == .summary {
                    last.showAvatar = false
                    self.messages[self.messages.count - 1] = last
                    self.tableView.reloadRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .none)
                }
                self.viewModel.fetchHotels(for: data)
            }
            
            return cell
            
        case .hotelCard:
            guard let hotelData = message.payload as? HotelWithRooms else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeue(HotelChatCell.self, for: indexPath)
            cell.configure(with: hotelData.hotel, rooms: hotelData.rooms, showAvatar: message.showAvatar)
            
            cell.onViewDetails = { [weak self] in
                guard let self = self else {
                    print("self is nil, can't navigate")
                    return
                }
                guard let parsed = viewModel.lastSearchData else { return }
                let params = parsed.toHotelSearchParameters()
                let vc = HotelDetailVC(viewModel: HotelDetailVM(hotel: hotelData.hotel, rooms: hotelData.rooms, searchParams: params))
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.onSelectRoom = { [weak self] in
                guard let self = self else { return }
                self.viewModel.selectedHotel = hotelData.hotel
                self.appendMessage("🛏️ Please select your room type for \(hotelData.hotel.name):", sender: .bot)
                
                for (index, room) in hotelData.rooms.enumerated() {
                    let isLast = index == hotelData.rooms.count - 1
                    let message = ChatMessage(sender: .bot, text: "", type: .roomOption, payload: room, showAvatar: isLast)
                    self.appendMessage(message)
                }
            }
            
            return cell
            
        case .roomOption:
            guard let room = message.payload as? Room else {
                return UITableViewCell()
            }
            let cell = tableView.dequeue(RoomChatCell.self, for: indexPath)
            cell.configure(with: room, showAvatar: message.showAvatar)
            
            cell.onSelectTapped = { [weak self] in
                self?.appendMessage("✅ Room \(room.roomNumber) selected. Let's complete your reservation.", sender: .bot)
                self?.viewModel.selectedRoom = room
                self?.viewModel.startCollectingUserInfo()
            }
            
            return cell
            
        case .bookingConfirm:
            let cell = tableView.dequeue(ChatBubbleCell.self, for: indexPath)
            cell.configure(with: message)
            cell.addConfirmationButton(title: "✅ Confirm Booking") { [weak self] in
                self?.viewModel.confirmReservationFromChat()
            }
            return cell
        }
    }
}

extension ChatbotVC: ChatbotVMDelegate {
    func didReceiveSearchData(_ data: ParsedSearchData) {
        print("📩 Received parsed search data:", data)

        guard !data.destination.isEmpty else {
            appendMessage("❌ I couldn't understand the destination. Could you try again?", sender: .bot)
            return
        }

        viewModel.lastSearchData = data
        
        let summary = """
        Destination: \(data.destination)
        Check-in: \(data.checkIn)
        Check-out: \(data.checkOut)
        Guests: \(data.guestCount)
        Rooms: \(data.roomCount)
        """

        appendMessage(summary, sender: .bot, type: .summary, payload: data)
    }
    
    func didReceiveHotelMessages(_ hotelMessages: [ChatMessage]) {
        for message in hotelMessages { messages.append(message) }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    func didFailWithError(_ error: Error) {
        appendMessage("⚠️ Error: \(error.localizedDescription)", sender: .bot)
    }
}
