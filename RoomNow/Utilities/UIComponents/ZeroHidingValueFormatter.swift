//
//  ZeroHidingValueFormatter.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import DGCharts

class ZeroHidingValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        return value == 0 ? "" : "\(Int(value))"
    }
}
