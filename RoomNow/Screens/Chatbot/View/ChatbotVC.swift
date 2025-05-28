//
//  ChatbotVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit
import IQKeyboardManagerSwift

final class ChatbotVC: UIViewController {
    
    private let tableView = UITableView()
    private let inputTextView = UITextView()
    private let sendButton = UIButton(type: .system)
    
    private var messages: [ChatMessage] = []
    private var lastParsedSearchData: ParsedSearchData?
    private let viewModel = ChatbotVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavBar()
        viewModel.delegate = self
        viewModel.loadAvailableCities()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.viewModel.sendInitialGreeting()
        }
        keyboardObserver()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.isEnabled = true
    }

    private var inputTextViewHeightConstraint: NSLayoutConstraint!
    private var inputContainerBottomConstraint: NSLayoutConstraint!


    private func setupUI() {
        view.backgroundColor = .appBackground
        navigationItem.title = "Assistant"

        // Table View
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        tableView.registerCell(type: ChatBubbleCell.self)
        tableView.registerCell(type: HotelChatCell.self)
        tableView.registerCell(type: SummaryChatCell.self)
        tableView.registerCell(type: RoomChatCell.self)

        // Input Text View
        inputTextView.font = .systemFont(ofSize: 16)
        inputTextView.layer.cornerRadius = 8
        inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.isScrollEnabled = false
        inputTextView.delegate = self
        inputTextView.translatesAutoresizingMaskIntoConstraints = false

        // Send Button
        sendButton.applyPrimaryChatStyle(with: "Send")
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        // Input Container
        let inputContainer = UIStackView(arrangedSubviews: [inputTextView, sendButton])
        inputContainer.axis = .horizontal
        inputContainer.spacing = 8
        inputContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(inputContainer)

        // Input height constraint (grows dynamically)
        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 40)
        inputTextViewHeightConstraint.isActive = true
        
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            inputContainerBottomConstraint,
            inputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            inputTextView.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
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
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        appendMessage(text, sender: .user)
        inputTextView.text = ""
        inputTextViewHeightConstraint.constant = 40
        view.layoutIfNeeded()

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
        tableView.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func appendMessage(_ message: ChatMessage) {
        messages.append(message)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func handleRoomSelectionChanged() {
        let result = viewModel.processRoomSelectionChange()

        if result.remaining > 0 {
            appendMessage("You need to select \(result.remaining) more room(s).", sender: .bot)
        } else {
            if result.enoughBeds {
                let message = ChatMessage(
                    sender: .bot,
                    text: "✅ You've selected all required rooms. Tap below to continue.",
                    type: .roomConfirm,
                    payload: viewModel.selectedRooms,
                    showAvatar: true
                )
                appendMessage(message)
            } else {
                appendMessage("⚠️ The selected rooms can't accommodate all guests. Please adjust your selection.", sender: .bot)
            }
        }
    }
    
    private func keyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        inputContainerBottomConstraint.constant = -keyboardFrame.height + view.safeAreaInsets.bottom - 16

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        inputContainerBottomConstraint.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
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
                
                let availableRooms = hotelData.rooms.filter {
                    $0.isAvailable(for: self.viewModel.lastSearchData!.toHotelSearchParameters().checkInDate,
                                   checkOut: self.viewModel.lastSearchData!.toHotelSearchParameters().checkOutDate)
                }

                for (index, room) in availableRooms.enumerated() {
                    let isLast = index == availableRooms.count - 1
                    let message = ChatMessage(sender: .bot, text: "", type: .roomOption, payload: room, showAvatar: isLast)
                    self.appendMessage(message)
                }

                if availableRooms.isEmpty {
                    self.appendMessage("❌ No rooms available for the selected dates.", sender: .bot)
                }
            }
            
            return cell
            
        case .roomOption:
            guard let room = message.payload as? Room else { return UITableViewCell() }
            let cell = tableView.dequeue(RoomChatCell.self, for: indexPath)
            
            let isSelected = viewModel.selectedRooms.contains(where: { $0.id == room.id })

            if isSelected {
                cell.configure(
                    with: room,
                    showAvatar: message.showAvatar,
                    buttonTitle: "❌ Remove Room"
                ) { [weak self] in
                    guard let self else { return }
                    self.viewModel.selectedRooms.removeAll { $0.id == room.id }
                    self.appendMessage("🗑️ Room \(room.roomNumber) removed.", sender: .bot)
                    self.handleRoomSelectionChanged()
                }
            } else {
                cell.configure(
                    with: room,
                    showAvatar: message.showAvatar,
                    buttonTitle: "✅ Select Room"
                ) { [weak self] in
                    guard let self else { return }
                    self.viewModel.selectedRooms.append(room)
                    self.appendMessage("✅ Room \(room.roomNumber) selected.", sender: .bot)
                    self.handleRoomSelectionChanged()
                }
            }

            return cell
            
        case .roomConfirm:
            let cell = tableView.dequeue(ChatBubbleCell.self, for: indexPath)
            cell.configure(with: message)
            cell.addConfirmationButton(title: "✅ Confirm Rooms") { [weak self] in
                self?.viewModel.startCollectingUserInfo()
            }
            return cell
            
        case .loginPrompt:
            let cell = tableView.dequeue(ChatBubbleCell.self, for: indexPath)
            cell.configure(with: message)
            cell.addConfirmationButton(title: "🔐 Log In") { [weak self] in
                guard let tabBarVC = self?.tabBarController as? TabBarVC else { return }
                tabBarVC.selectedIndex = 3
            }
            return cell
            
        case .bookingConfirm:
            let cell = tableView.dequeue(ChatBubbleCell.self, for: indexPath)
            cell.configure(with: message)
            cell.addConfirmationButton(title: "Confirm Booking") { [weak self] in
                self?.viewModel.confirmReservationFromChat()
            }
            return cell
        }
    }
}

extension ChatbotVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        inputTextViewHeightConstraint.constant = min(120, estimatedSize.height)
        view.layoutIfNeeded()
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
        for message in hotelMessages {
            messages.append(message)
        }
        tableView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func didFailWithError(_ error: Error) {
        appendMessage("⚠️ Error: \(error.localizedDescription)", sender: .bot)
    }
    
    func shouldNavigateToBookings() {
        tabBarController?.selectedIndex = 2
    }
}
