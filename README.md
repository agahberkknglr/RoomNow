<p align="center">
  <img src="RoomNow/Resources/Assets.xcassets/Images/roomnow-logo.imageset/roomnow-logo.png" alt="RoomNow App Icon" width="631" height="140">
</p>
<div  align="center">
<h1> RoomNow </h1>
<h2> Agah Berkin Güler </h2>
</div>
 
Welcome to RoomNow. This is an iOS hotel reservation app where users can search, view, and book hotels with support for multi-room selection, user profiles, and an AI chatbot assistant. Admins can manage cities, hotels, rooms, users, and reservations.

## Table of Contents
- [Features](#features)
  - [Screenshots](#screenshots)
  - [Tech Stack](#tech-stack)
  - [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Search & Results](#search--results)
  - [Hotel Detail](#hotel-detail)
  - [Reservation](#reservation)
  - [Saved Hotels](#saved-hotels)
  - [Profile](#profile)
  - [Admin Panel](#admin-panel)
- [AI Chatbot Assistant](#ai-chatbot-assistant)
- [Known Issues](#known-issues)
- [Improvements](#improvements)

## Features

**User Experience:**
- 🔍 Search hotels by city, dates, guests.
- 🏨 View hotel detail with rooms, map, and amenities.
- 💬 AI Chatbot assistant for guided hotel booking.
- 🛏️ Multi-room selection and dynamic availability.
- 💾 Save favorite hotels.
- 👤 Profile screen with editable details and profile image.

**Admin Panel:**
- 🏙️ Manage cities, hotels, and rooms.
- 📊 View all reservations and analytics.
- 👥 List all users with filter & search options.

## Screenshots
| Register | Sign In | 
|-----------------------------------|-----------------------------------|
| <img src="/Screenshots/register.png" width="250"/> | <img src="/Screenshots/signin.png" width="250"/> 

### User

| Search | Result | Detail | Room Selection | Personal Info | Booking Confirm |
|-----------------------------------|-----------------------------------|-----------------------------------|-----------------------------------|-----------------------------------|-----------------------------------|
|<img src="/Screenshots/search.png" width="250"/> | <img src="/Screenshots/result.png" width="250"/> | <img src="/Screenshots/detail.png" width="250"/> | <img src="/Screenshots/roomselect.png" width="250"/> | <img src="/Screenshots/info.png" width="250"/> | <img src="/Screenshots/bookingsum.png" width="250"/>

| Bookings | Bookings Detail | Chat | Chat Booking Confirm |
|-----------------------------------|-----------------------------------|-----------------------------------|-----------------------------------|
|<img src="/Screenshots/bookings.png" width="250"/> |<img src="/Screenshots/bookingsdetail.png" width="250"/> |<img src="/Screenshots/chat assistant.png" width="250"/> |<img src="/Screenshots/chat confirm booking.png" width="250"/> 

### Admin
| Dashboard | Add Hotel | Edit Hotel | Room List | Add/Edit Room |
|-----------------------------------|-----------------------------------|-----------------------------------|-----------------------------------|-----------------------------------|
|<img src="/Screenshots/dashboard.png" width="250"/> | <img src="/Screenshots/addhotel.png" width="250"/> | <img src="/Screenshots/edithotel.png" width="250"/> | <img src="/Screenshots/roomlist.png" width="250"/> | <img src="/Screenshots/editroom.png" width="250"/> 

| Tools | All Reservations | All Users | Analytics |
|-----------------------------------|-----------------------------------|-----------------------------------|-----------------------------------|
|<img src="/Screenshots/tools.png" width="250"/> | <img src="/Screenshots/allreservations.png" width="250"/> | <img src="/Screenshots/allusers.png" width="250"/> | <img src="/Screenshots/analytics.png" width="250"/>  

## Tech Stack

- **Xcode:** Version 16.2
- **Language:** Swift 6.0.3
- **Architecture:** MVVM
- **Backend:** Firebase (Firestore, Auth)
- **Libraries:**
  - SDWebImage
  - FSCalendar
  - Charts

  ## Architecture

RoomNow uses the MVVM architecture to separate UI from business logic, making it easier to test and maintain. Firebase handles backend services, and programmatic UI ensures flexibility and performance.

## Getting Started

### Prerequisites

- Xcode 16 or later
- Swift Package Manager

### Installation

```bash
git clone https://github.com/your-username/RoomNow.git
cd RoomNow
open RoomNow.xcworkspace
```

- Add your `GoogleService-Info.plist` file from Firebase.
- Run on a simulator or physical device (iOS 16.1+).


## Usage

### Search & Results
- Tap "Destination", "Date", and "Guests" to set parameters.
- Search returns hotels matching the criteria.

### Hotel Detail
- View hotel name, image slider, amenities, room types.
- Book available rooms with real-time availability.

### Reservation
- Select multiple rooms if needed.
- See summary and confirm booking.
- View bookings and cancel upcoming ones.

### Saved Hotels
- Save/un-save hotels with the bookmark icon.
- View all saved hotels grouped by city.

### Profile
- Sign in / Register with Firebase Auth.
- Edit profile image, name, gender, date of birth.

### Admin Panel
- Add/edit/delete cities, hotels, and rooms.
- View and filter all user reservations.
- Track app usage with basic analytics.

## AI Chatbot Assistant

RoomNow includes an AI-powered chatbot that guides users through the hotel search and booking process in a conversational way. This feature improves accessibility and user experience by allowing natural language interactions.

### 🔹 Key Capabilities
- Understands user intent from chat input
- Asks follow-up questions to collect missing details like:
  - Destination city
  - Check-in/check-out dates
  - Number of guests and rooms
- Returns matching hotel results based on parsed input
- Supports reservation flow entirely through the chat interface

### 🔹 Tech Stack
- Integrated with [n8n](https://n8n.io/) for conversational flow control
- Webhook system to interact with the AI backend
- Integrated into MVVM architecture with ChatbotViewModel

### 🔹 Example Flow
1. **User**: “I want to book a hotel in Istanbul for 2 people this weekend.”
4. **Chatbot**: *Shows hotels in Istanbul available for 2 nights, 2 guests.*

## Known Issues
- Hotel detail loading delay when there are many base64 images.
- Room selection UI glitches after selection a room from end of the collection view row.
- Calendar UI glitch on rare edge cases.

## Improvements
- Add localization for multiple languages.
- Improve map accuracy and route to hotel.
- Enable re-booking from booking history.
- Add user reviews and hotel ratings.