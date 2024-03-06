//
//  ViewController.swift
//  LocalNotification_UIKit
//
//  Created by Sadia on 6/3/24.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { permissionGranted, error in
            if(!permissionGranted){
                print("Premission Denied")
            }
        }
    }
    
    @IBAction func scheduleAction(_ sender: UIButton) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                guard let title = self.titleTextField.text else{return}
                guard let message = self.messageTextField.text else{return}
                let date = self.datePicker.date
                
                if (settings.authorizationStatus == .authorized){
                    self.createScheduleNotifications(title: title, message: message, scheduleDate: date)
                }
                else{
                    self.showGoToSettingScreenAlert()
                }
            }
        }
    }
    
    
    
    func createScheduleNotifications(title: String, message: String, scheduleDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        self.notificationCenter.add(request) { error in
            if let error {
                print("Error :"+error.localizedDescription)
                return
            }
        }
        
        self.showAlert(title: "Notification scheduled", message: "At "+self.formattedDate(date: scheduleDate))
    }

    
    
    func showAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true)
    }
    
    
    func formattedDate(date: Date) -> String{
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM y HH:mm"
            return formatter.string(from: date)
    }
    
    
    
    func showGoToSettingScreenAlert() -> Void {
        let ac = UIAlertController(title: "Enable Notifications?", message: "To use this feature you must enable notifications in settings", preferredStyle: .alert)
        let goToSettings = UIAlertAction(title: "Settings", style: .default)
        { (_) in
            guard let setttingsURL = URL(string: UIApplication.openSettingsURLString)
            else
            {
                return
            }
            
            if(UIApplication.shared.canOpenURL(setttingsURL))
            {
                UIApplication.shared.open(setttingsURL) { (_) in}
            }
        }
        ac.addAction(goToSettings)
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in}))
        self.present(ac, animated: true)
    }
}

