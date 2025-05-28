//
//  ChatbotVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import Foundation

enum ChatInputStep {
    case idle
    case askingName
    case askingEmail
    case askingPhone
    case askingNote
}

protocol ChatbotVMDelegate: AnyObject {
    func didReceiveSearchData(_ data: ParsedSearchData)
    func didReceiveHotelMessages(_ messages: [ChatMessage])
    func didFailWithError(_ error: Error)
}

final class ChatbotVM {
    
    weak var delegate: ChatbotVMDelegate?
    private(set) var messages: [(String, String)] = []
    private var messageHistory: [String] = []
    var inputStep: ChatInputStep = .idle
    var userInfo = UserReservationInfo()
    var lastSearchData: ParsedSearchData?
    var selectedHotel: Hotel?
    var selectedRooms: [Room] = []
    var availableCities: [String] = []
    
    func sendMessage(_ userMessage: String) {
        messages.append((userMessage, "⏳"))
        messageHistory.append("User: \(userMessage)")
        
        let fullConversation = messageHistory.joined(separator: "\n")
        
        NetworkManager.shared.sendChatMessage(fullConversation) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let lastIndex = self?.messages.indices.last {
                        self?.messages[lastIndex].1 = "Parsed"
                    }
                    self?.handleParsedSearchData(data)

                case .failure(let error):
                    if let lastIndex = self?.messages.indices.last {
                        self?.messages[lastIndex].1 = "Error"
                    }
                    self?.delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    func sendInitialGreeting() {
        let greeting = ChatMessage(
            sender: .bot,
            text: "👋 Hi! I'm your travel assistant. You can tell me where and when you want to go, and I’ll help you find a hotel.",
            type: .text,
            payload: nil,
            showAvatar: true
        )
        delegate?.didReceiveHotelMessages([greeting])
    }
    
    func loadAvailableCities() {
        FirebaseManager.shared.fetchCities { [weak self] result in
            if case .success(let cities) = result {
                self?.availableCities = cities.map { $0.name.lowercased() }
            }
        }
    }
    
    func handleParsedSearchData(_ parsed: ParsedSearchData) {
        let validCities = availableCities

        let normalizedDestination = parsed.destination.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard validCities.contains(normalizedDestination) else {
            delegate?.didReceiveHotelMessages([
                ChatMessage(
                    sender: .bot,
                    text: "❌ Sorry, we couldn't find any results for \"\(parsed.destination)\". Please check the spelling or try another city.",
                    type: .text,
                    payload: nil
                )
            ])
            return
        }
        delegate?.didReceiveSearchData(parsed)
    }
    
    func fetchHotels(for data: ParsedSearchData) {
        let parameters = data.toHotelSearchParameters()
        
        FirebaseManager.shared.fetchHotels(searchParameters: parameters) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let hotelResults):
                    if hotelResults.isEmpty {
                        print("Hotel results \(hotelResults)")
                        self?.delegate?.didReceiveHotelMessages([
                            ChatMessage(
                                sender: .bot,
                                text: "❌ Sorry, there are no available hotels in **\(data.destination.capitalized)** for the selected dates. Please try a different city or change your search.",
                                type: .text,
                                payload: nil
                            )
                        ])
                        return
                    } else {
                        let messages: [ChatMessage] = hotelResults.enumerated().map { (index, tuple) in
                            let hotel = tuple.hotel
                            let rooms = tuple.rooms
                            let price = Int(rooms.first?.price ?? 0)

                            let text = """
                            🏨 \(hotel.name.capitalized)
                            📍 \(hotel.city), \(hotel.location)
                            ₺\(price) / night
                            """

                            let wrapped = HotelWithRooms(hotel: hotel, rooms: rooms)
                            let isLast = index == hotelResults.count - 1

                            return ChatMessage(
                                sender: .bot,
                                text: text,
                                type: .hotelCard,
                                payload: wrapped,
                                showAvatar: isLast
                            )
                        }

                        self?.delegate?.didReceiveHotelMessages(messages)
                    }
                case .failure(let error):
                    self?.delegate?.didReceiveHotelMessages([
                        ChatMessage(sender: .bot, text: "❌ Failed to fetch hotels: \(error.localizedDescription)", type: .text, payload: nil)
                    ])
                }
            }
        }
    }
    
    func handleRoomSelection(_ room: Room) {
        if !selectedRooms.contains(where: { $0.roomNumber == room.roomNumber }) {
            selectedRooms.append(room)
        } else {
            selectedRooms.removeAll { $0.roomNumber == room.roomNumber }
        }
    }
    
    func processRoomSelectionChange() -> (remaining: Int, enoughBeds: Bool) {
        let requiredRoomCount = lastSearchData?.roomCount ?? 1
        let guestCount = lastSearchData?.guestCount ?? 1

        let selectedCount = selectedRooms.count
        let totalBeds = selectedRooms.reduce(0) { $0 + $1.bedCapacity }

        let remaining = requiredRoomCount - selectedCount
        let enoughBeds = totalBeds >= guestCount

        return (remaining, enoughBeds)
    }

    
    func startCollectingUserInfo() {
        guard let _ = AuthManager.shared.currentUser else {
            delegate?.didReceiveHotelMessages([
                ChatMessage(
                    sender: .bot,
                    text: "🔐 To complete your reservation, please sign in from the profile tab.",
                    type: .loginPrompt,
                    payload: nil,
                    showAvatar: true
                )
            ])
            return
        }
        
        if let cachedUser = AuthManager.shared.currentAppUser {
            fillFrom(user: cachedUser)
            askNextInfoFieldIfNeeded()
        } else {
            AuthManager.shared.fetchUserData { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self?.fillFrom(user: user)
                        self?.askNextInfoFieldIfNeeded()
                    case .failure(let error):
                        print("❌ Could not fetch user data:", error)
                        self?.inputStep = .askingName
                        self?.delegate?.didReceiveHotelMessages([
                            ChatMessage(sender: .bot, text: "👤 What's your full name?", type: .text, payload: nil)
                        ])
                    }
                }
            }
        }
    }
    
    private func fillFrom(user: AppUser) {
        userInfo.name = user.username
        userInfo.email = user.email
    }
    
    private func askNextInfoFieldIfNeeded() {
        if userInfo.name?.isEmpty ?? true {
            inputStep = .askingName
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "👤 What's your full name?", type: .text, payload: nil)
            ])
        } else if userInfo.email?.isEmpty ?? true {
            inputStep = .askingEmail
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "📧 What's your email address?", type: .text, payload: nil)
            ])
        } else if userInfo.phone?.isEmpty ?? true {
            inputStep = .askingPhone
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "📱 What's your phone number?", type: .text, payload: nil)
            ])
        } else {
            inputStep = .askingNote
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "📝 Any notes you'd like to add? (Optional — type 'skip')", type: .text, payload: nil)
            ])
        }
    }
    
    func handleUserInput(_ text: String) {
        if text.lowercased() == "cancel" {
            resetConversation()
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "🔄 Reservation cancelled. You can start again.", type: .text, payload: nil)
            ])
            return
        }
        
        if text.lowercased() == "confirm rooms" {
            if selectedRooms.isEmpty {
                delegate?.didReceiveHotelMessages([
                    ChatMessage(sender: .bot, text: "❌ You haven't selected any rooms.", type: .text, payload: nil)
                ])
                return
            }
            startCollectingUserInfo()
            return
        }
        
        if text.lowercased().starts(with: "remove") {
            handleRoomRemovalCommand(text)
            return
        }
        
        switch inputStep {
        case .askingName:
            userInfo.name = text
            inputStep = .askingEmail
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "📧 What's your email address?", type: .text, payload: nil)
            ])

        case .askingEmail:
            userInfo.email = text
            inputStep = .askingPhone
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "📱 What's your phone number?", type: .text, payload: nil)
            ])

        case .askingPhone:
            userInfo.phone = text
            inputStep = .askingNote
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "📝 Any notes? (Optional — type 'skip')", type: .text, payload: nil)
            ])

        case .askingNote:
            userInfo.note = (text.lowercased() == "skip" ? nil : text)
            inputStep = .idle
            showBookingSummary()

        case .idle:
            sendMessage(text) // original n8n call
        }
    }

    
    func showBookingSummary() {
        guard let search = lastSearchData,  let selectedHotel = selectedHotel, !selectedRooms.isEmpty else { return }

        let totalPrice = selectedRooms.reduce(0) { $0 + Int($1.price) }
        let roomNumbers = selectedRooms.map { $0.roomNumber }.joined(separator: ", ")

        let summary = """
        ✅ Here's your reservation:
        🏨 \(selectedHotel.name)
        🛏 Rooms \(roomNumbers) - ₺\(totalPrice) total
        📍 \(search.destination)
        📅 \(search.toShortReadableDate(from: search.checkIn)) to \(search.toShortReadableDate(from: search.checkOut))
        👤 \(userInfo.name ?? "-")
        📧 \(userInfo.email ?? "-")
        📱 \(userInfo.phone ?? "-")
        📝 \(userInfo.note ?? "-")

        Tap to confirm your booking ✅
        """

        let message = ChatMessage(
            sender: .bot,
            text: summary,
            type: .bookingConfirm,
            payload: selectedRooms,
            showAvatar: true
        )

        delegate?.didReceiveHotelMessages([message])
    }
    
    func confirmReservationFromChat() {
        guard AuthManager.shared.currentUser != nil else {
            delegate?.didReceiveHotelMessages([
                ChatMessage(
                    sender: .bot,
                    text: "❌ You must be signed in to confirm your booking.",
                    type: .text,
                    payload: nil
                )
            ])
            return
        }
        guard
            let hotel = selectedHotel,
            !selectedRooms.isEmpty,
            let parsed = lastSearchData
        else {
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "❌ Missing reservation data.", type: .text, payload: nil)
            ])
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard
            let checkIn = formatter.date(from: parsed.checkIn),
            let checkOut = formatter.date(from: parsed.checkOut)
        else {
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "❌ Invalid dates.", type: .text, payload: nil)
            ])
            return
        }
        
        let roomNumbers = selectedRooms.map { $0.roomNumber }
        let totalPrice = selectedRooms.reduce(0) { $0 + Int($1.price) }

        let reservation = Reservation(
            hotelId: hotel.id ?? "",
            hotelName: hotel.name,
            city: hotel.city,
            checkInDate: checkIn,
            checkOutDate: checkOut,
            guestCount: parsed.guestCount,
            roomCount: 1,
            selectedRoomNumbers: roomNumbers,
            totalPrice: totalPrice,
            fullName: userInfo.name ?? "",
            email: userInfo.email ?? "",
            phone: userInfo.phone ?? "",
            note: userInfo.note,
            reservedAt: Date(),
            status: .active,
            completedAt: nil,
            cancelledAt: nil
        )

        FirebaseManager.shared.saveReservation(reservation) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateMultipleRoomDatesForChat(
                    roomIds: self.selectedRooms.compactMap { $0.id },
                    checkIn: checkIn,
                    checkOut: checkOut
                )
            case .failure(let error):
                self.delegate?.didReceiveHotelMessages([
                    ChatMessage(sender: .bot, text: "❌ Booking failed: \(error.localizedDescription)", type: .text, payload: nil)
                ])
            }
        }
    }

    private func updateMultipleRoomDatesForChat(roomIds: [String], checkIn: Date, checkOut: Date) {
        let group = DispatchGroup()
        var failedRooms: [String] = []

        for roomId in roomIds {
            group.enter()
            FirebaseManager.shared.updateBookedDates(for: roomId, startDate: checkIn, endDate: checkOut) { result in
                if case .failure = result {
                    failedRooms.append(roomId)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if failedRooms.isEmpty {
                self.delegate?.didReceiveHotelMessages([
                    ChatMessage(sender: .bot, text: "🎉 Booking confirmed! Thank you.", type: .text, payload: nil)
                ])
            } else {
                self.delegate?.didReceiveHotelMessages([
                    ChatMessage(sender: .bot, text: "⚠️ Booking confirmed, but some rooms couldn't be updated.", type: .text, payload: nil)
                ])
            }

            self.resetConversation()
        }
    }
    
    private func handleRoomRemovalCommand(_ text: String) {
        let trimmed = text.replacingOccurrences(of: "remove", with: "").trimmingCharacters(in: .whitespaces)

        if trimmed == "all" {
            selectedRooms.removeAll()
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "🗑 All selected rooms removed.", type: .text, payload: nil)
            ])
            return
        }

        if let index = selectedRooms.firstIndex(where: { $0.roomNumber == trimmed }) {
            let removed = selectedRooms.remove(at: index)
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "🗑 Room \(removed.roomNumber) removed.", type: .text, payload: nil)
            ])
        } else {
            delegate?.didReceiveHotelMessages([
                ChatMessage(sender: .bot, text: "⚠️ Could not find room \(trimmed) in your selection.", type: .text, payload: nil)
            ])
        }
    }
    
    func resetConversation() {
        inputStep = .idle
        userInfo = UserReservationInfo()
        selectedRooms = []
        selectedHotel = nil
        lastSearchData = nil
        messages.removeAll()
    }
}

