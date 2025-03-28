//
//  DateVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 25.03.2025.
//

import UIKit
import FSCalendar

protocol DateVCDelegate: AnyObject {
    func didSelectDateRange(_ startDate: Date, _ endDate: Date)
}

class DateVC: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select dates"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let calendar:FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.allowsMultipleSelection = true
        calendar.firstWeekday = 2
        calendar.scrollDirection = .vertical
        calendar.appearance.borderRadius = 0
        calendar.appearance.borderDefaultColor = .clear
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.headerTitleAlignment = .right
        calendar.appearance.headerTitleOffset = CGPoint(x: -16, y: 0)
        calendar.placeholderType = .none
        calendar.appearance.todayColor = .clear
        return calendar
    }()
    
    private let selectDatesButton = UIButton()
    
    private var selectedDates:[Date] = []
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    
    weak var delegate: DateVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupUI()
        
        calendar.delegate = self
        calendar.dataSource = self
        selectDatesButton.addTarget(self, action: #selector(selectDatesButtonTapped), for: .touchUpInside)
        
        if let start = selectedStartDate, let end = selectedEndDate {
            calendar.select(start)
            calendar.select(end)
            selectedDates = [start, end]
        }

    }
    
    @objc private func selectDatesButtonTapped() {
        print(selectedDates)
        if selectedDates.count == 2 {
            selectedDates.sort()
            delegate?.didSelectDateRange(selectedDates.first!, selectedDates.last!)
        }
        dismiss(animated: true)
    }

    
    private func setupUI() {
        //view.addSubview(titleLabel)
        //view.addSubview(calendar)
        //view.addSubview(selectDatesButton)
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, calendar, selectDatesButton])
            stackView.axis = .vertical
            stackView.distribution = .fillProportionally
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()

        view.addSubview(stackView)
        
        selectDatesButton.setTitle("Select Dates", for: .normal)
        selectDatesButton.layer.cornerRadius = 10
        selectDatesButton.tintColor = .white
        selectDatesButton.backgroundColor = .brown

        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            //titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            //titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            //
            //calendar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            //calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            //calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendar.heightAnchor.constraint(equalToConstant: 300),
            
            selectDatesButton.widthAnchor.constraint(equalToConstant: 100),
            selectDatesButton.heightAnchor.constraint(equalToConstant: 50)
            
            
        ])
        
    }
}

extension DateVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let istanbulTimeZone = TimeZone(identifier: "Europe/Istanbul")!
        var calendarComponents = Calendar.current.dateComponents(in: istanbulTimeZone, from: date)
        calendarComponents.timeZone = istanbulTimeZone
        let istanbulDate = Calendar.current.date(from: calendarComponents)!

        if selectedDates.count < 2 {
            selectedDates.append(istanbulDate)
        } else {
            if let firstDate = selectedDates.first {
                calendar.deselect(firstDate)
                selectedDates.removeFirst()
            }
            selectedDates.append(istanbulDate)
        }
    }
    
    private func formattedDateRange() -> String? {
        guard selectedDates.count == 2 else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")

        let startDate = formatter.string(from: selectedDates.first!)
        let endDate = formatter.string(from: selectedDates.last!)

        return "\(startDate) - \(endDate)"
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return date >= Date()
    }
}

extension DateVC: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let today = Calendar.current.startOfDay(for: Date())

        // Get first and last day of the current month
        let components = Calendar.current.dateComponents([.year, .month], from: today)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        let lastDayOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
        
        if date == today {
            return .systemBrown // Change only the text color for today's date
        } else if date < today && date >= firstDayOfMonth {
            return .lightGray // Gray out past dates in the current month
        } else if date < firstDayOfMonth {
            return .clear // Hide dates from previous months
        } else {
            return .label // Default color for future dates
        }
    }

    
    
}

extension DateVC: FSCalendarDataSource {

}


