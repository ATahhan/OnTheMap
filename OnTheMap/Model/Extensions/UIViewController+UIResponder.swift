//
//  UIViewController.swift
//  OnTheMap
//
//  Created by Ammar AlTahhan on 20/11/2018.
//  Copyright © 2018 Ammar AlTahhan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    func startAnActivityIndicator() -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(style: .gray)
        self.view.addSubview(ai)
        self.view.bringSubviewToFront(ai)
        ai.center = self.view.center
        ai.hidesWhenStopped = true
        ai.startAnimating()
        return ai
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func subscribeToNotificationsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromNotificationsObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let textField = UIResponder.currentFirstResponder as? UITextField else { return }
        let keyboardHeight = getKeyboardHeight(notification)
        
        // kbMinY is minY of the keyboard rect
        let kbMinY = (view.frame.height-keyboardHeight)
        
        // Check if the current textfield is covered by the keyboard
        var bottomCenter = textField.center
        bottomCenter.y += textField.frame.height/2
        let textFieldMaxY = textField.convert(bottomCenter, to: self.view).y
        if textFieldMaxY - kbMinY > 0 {
            
            // Displace the view's origin by the difference between kb's minY and textfield's maxY
            view.frame.origin.y = -(textFieldMaxY - kbMinY)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notifition: Notification) -> CGFloat {
        let userInfo = notifition.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

extension UIResponder {
    
    private static weak var _currentFirstResponder: UIResponder?
    
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        
        return _currentFirstResponder
    }
    
    @objc func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
