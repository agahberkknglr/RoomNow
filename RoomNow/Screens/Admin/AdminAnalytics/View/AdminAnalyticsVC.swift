//
//  AdminAnalyticsVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.06.2025.
//

import UIKit
import DGCharts

final class AdminAnalyticsVC: UIViewController {

    private let viewModel: AdminAnalyticsVMProtocol = AdminAnalyticsVM()

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let barChartView = BarChartView()
    private let pieChartView = PieChartView()
    private let lineChartView = LineChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
        view.backgroundColor = .appBackground
        setupUI()
        fetchData()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        [barChartView, pieChartView, lineChartView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 250).isActive = true
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.backgroundColor = .secondarySystemGroupedBackground
            contentStackView.addArrangedSubview($0)
        }
    }

    private func fetchData() {
        showLoadingIndicator()
        viewModel.fetchAnalytics { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.updateBarChart()
                self?.updatePieChart()
                self?.updateLineChart()
            }
        }
    }

    private func updateBarChart() {
        let entries = [
            BarChartDataEntry(x: 0, y: Double(viewModel.totalUsers)),
            BarChartDataEntry(x: 1, y: Double(viewModel.totalHotels)),
            BarChartDataEntry(x: 2, y: Double(viewModel.totalReservations))
        ]

        let dataSet = BarChartDataSet(entries: entries, label: "Counts")
        dataSet.colors = [UIColor.systemBlue, UIColor.systemGreen, UIColor.systemOrange]
        dataSet.valueFont = .systemFont(ofSize: 14, weight: .medium)

        let data = BarChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(formatter: NumberFormatter.integerFormatter))

        barChartView.data = data
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Users", "Hotels", "Reservations"])
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.animate(yAxisDuration: 1.0)
        barChartView.chartDescription.text = "User / Hotel / Reservation Counts"
    }

    private func updatePieChart() {
        let pieEntries = viewModel.genderStats.map {
            PieChartDataEntry(value: Double($0.value), label: $0.key)
        }

        let pieDataSet = PieChartDataSet(entries: pieEntries)
        pieDataSet.entryLabelColor = .label
        pieDataSet.colors = ChartColorTemplates.material()
        pieDataSet.valueFont = .systemFont(ofSize: 14, weight: .medium)

        pieChartView.data = PieChartData(dataSet: pieDataSet)
        pieChartView.centerText = "Gender Distribution"
        pieChartView.animate(yAxisDuration: 1.0)
        pieChartView.chartDescription.text = "Users by Gender"
    }

    private func updateLineChart() {
        let filteredMonths = viewModel.monthlyReservations
            .filter { $0.value > 0 }
        let sorted = filteredMonths.sorted { monthOrderIndex($0.key) < monthOrderIndex($1.key) }

        let months = sorted.map { $0.key }
        let values = sorted.enumerated().map { index, item in
            ChartDataEntry(x: Double(index), y: Double(item.value))
        }

        let dataSet = LineChartDataSet(entries: values, label: "Monthly Reservations")
        dataSet.circleRadius = 4
        dataSet.circleColors = [.systemBlue]
        dataSet.colors = [.systemBlue]
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .medium)
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = true

        let data = LineChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(formatter: NumberFormatter.integerFormatter))

        lineChartView.data = data
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelRotationAngle = 0
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.axisMinimum = -0.5
        lineChartView.xAxis.axisMaximum = Double(months.count) - 0.5
        lineChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: NumberFormatter.integerFormatter)
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.chartDescription.text = "Monthly Reservations"
        lineChartView.animate(xAxisDuration: 1.0)
    }
    
    private func monthOrderIndex(_ month: String) -> Int {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return months.firstIndex(of: month) ?? 0
    }
}
