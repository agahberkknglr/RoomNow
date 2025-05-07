//
//  UIColor.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 7.05.2025.
//

import UIKit

extension UIColor {
    static var appBackground: UIColor {
        UIColor(named: "Background") ?? UIColor.black
    }

    static var appSecondaryBackground: UIColor {
        UIColor(named: "SecondaryBackground") ?? UIColor.darkGray
    }

    static var appPrimaryText: UIColor {
        UIColor(named: "PrimaryText") ?? UIColor.white
    }

    static var appSecondaryText: UIColor {
        UIColor(named: "SecondaryText") ?? UIColor.lightGray
    }

    static var appAccent: UIColor {
        UIColor(named: "Accent") ?? UIColor.systemTeal
    }
    
    static var appSecondaryAccent: UIColor {
        UIColor(named: "SecondaryAccent") ?? UIColor.systemTeal
    }

    static var appError: UIColor {
        UIColor(named: "Error") ?? UIColor.red
    }

    static var appWarning: UIColor {
        UIColor(named: "Warning") ?? UIColor.orange
    }

    static var appSuccess: UIColor {
        UIColor(named: "Success") ?? UIColor.green
    }

    static var appDivider: UIColor {
        UIColor(named: "Divider") ?? UIColor.gray
    }

    static var appDisabled: UIColor {
        UIColor(named: "Disabled") ?? UIColor.systemGray
    }

    static var appButtonBackground: UIColor {
        UIColor(named: "ButtonBackground") ?? UIColor.darkGray
    }

    static var appHighlight: UIColor {
        UIColor(named: "Highlight") ?? UIColor.black
    }
}
