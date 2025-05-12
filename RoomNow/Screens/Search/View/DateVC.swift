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

final class DateVC: UIViewController {

    private let viewModel: DateVMProtocol
    weak var delegate: DateVCDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select dates"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .appPrimaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.allowsMultipleSelection = true
        calendar.firstWeekday = 2
        calendar.scrollDirection = .vertical
        calendar.appearance.borderRadius = 1
        calendar.appearance.borderDefaultColor = .clear
        calendar.appearance.headerTitleColor = .appPrimaryText
        calendar.appearance.weekdayTextColor = .appPrimaryText
        calendar.appearance.headerTitleAlignment = .right
        calendar.appearance.headerTitleOffset = CGPoint(x: -16, y: 0)
        calendar.appearance.selectionColor = .appSecondaryAccent
        calendar.placeholderType = .none
        calendar.appearance.todayColor = .appButtonBackground
        return calendar
    }()

    private let selectDatesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select Dates", for: .normal)
        button.layer.cornerRadius = 10
        button.tintColor = .appPrimaryText
        button.backgroundColor = .appButtonBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var selectedStartDate: Date?
    var selectedEndDate: Date?

    init(viewModel: DateVMProtocol = DateVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()

        calendar.delegate = self
        calendar.dataSource = self
        selectDatesButton.addTarget(self, action: #selector(selectDatesButtonTapped), for: .touchUpInside)

        viewModel.preselectDates(start: selectedStartDate, end: selectedEndDate)

        calendar.selectedDates.forEach { calendar.deselect($0) }
        viewModel.selectedDates.forEach { calendar.select($0) }
    }

    @objc private func selectDatesButtonTapped() {
        guard let start = viewModel.selectedStartDate,
              let end = viewModel.selectedEndDate,
              start != end else {
            print("Invalid selection")
            return
        }

        delegate?.didSelectDateRange(start, end)
        dismiss(animated: true)
    }

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, calendar, selectDatesButton])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),

            calendar.heightAnchor.constraint(equalToConstant: 300),
            selectDatesButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - FSCalendarDelegate

extension DateVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let updated = viewModel.selectDate(date)

        calendar.selectedDates.forEach { calendar.deselect($0) }
        updated.forEach { calendar.select($0) }
    }

    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: date)
        return selected >= today
    }
}

// MARK: - FSCalendarDelegateAppearance

extension DateVC: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let today = Calendar.current.startOfDay(for: Date())

        let components = Calendar.current.dateComponents([.year, .month], from: today)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        let lastDayOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: firstDayOfMonth)!

        if date == today {
            return .appAccent
        } else if date < today && date >= firstDayOfMonth {
            return .lightGray
        } else if date < firstDayOfMonth {
            return .clear
        } else {
            return .appPrimaryText
        }
    }
}

extension DateVC: FSCalendarDataSource {}
