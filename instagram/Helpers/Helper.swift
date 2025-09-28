//
//  Helper.swift
//  instagram
//
//  Created by Müge Deniz on 10.11.2024.
//

import Foundation
import JGProgressHUD


class Helper {
    static let shared = Helper()
    let hud = JGProgressHUD()

    func showHud(text: String, view: UIView, isSuccessHud: Bool = false) {
        hud.textLabel.text = text
        hud.show(in: view)
        if isSuccessHud {
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.dismiss(afterDelay: 3)
        }
    }

    func hideHud() {
        hud.dismiss()
    }
    
    func generateRandomID(length: Int,
                          isNumber: Bool) -> String {
        var str = ""
        if isNumber {
            str = "0123456789"
        } else {
            str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        }
        return String((0..<length).compactMap { _ in str.randomElement() })
    }

}
