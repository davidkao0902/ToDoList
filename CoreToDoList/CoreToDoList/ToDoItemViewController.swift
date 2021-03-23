//
//  ToDoItemViewController.swift
//  CoreToDoList
//
//  Created by David Kao on 2021-03-23.
//

import UIKit
import CoreData

class ToDoItemViewController: UIViewController {
    
    var item: ToDoItem?
    var didDeleteItem = false
    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemNotesTextField: UITextField!

    @IBOutlet weak var itemDateSwitch: UISwitch!
    @IBOutlet weak var itemIsCompletedSwitch: UISwitch!
    @IBOutlet weak var itemDatePicker: UIDatePicker!
    
    @IBOutlet weak var doneButotn: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var isCompleted = false
        if(item?.isCompleted == true) {
            isCompleted = true
        }
        
        var needReminderDate = false
        if(item?.needReminderDate == true) {
            needReminderDate = true
        }
        
        
        itemTitleTextField.text = item?.title
        itemNotesTextField.text = item?.notes

        itemIsCompletedSwitch.isOn = isCompleted
        itemDateSwitch.isOn = needReminderDate
        itemDatePicker.date = item?.reminderDate ?? Date()
        
        if(itemDateSwitch.isOn) {
            itemDatePicker.isHidden = false
        }

        setButtonBorder(button: cancelButton, color: UIColor.systemBlue.cgColor)
        setButtonBorder(button: doneButotn, color: UIColor.systemBlue.cgColor)
        setButtonBorder(button: deleteButton, color: UIColor.systemRed.cgColor)
    }
    
    func setButtonBorder(button: UIButton, color: CGColor) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = color
    }
    
    

    @IBAction func cancelEditItem(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editItem(_ sender: Any) {
        item?.title = itemTitleTextField.text
        item?.notes = itemNotesTextField.text
        item?.isCompleted = itemIsCompletedSwitch.isOn
        item?.needReminderDate = itemDateSwitch.isOn
        
        if(!itemDateSwitch.isOn) {
            item?.reminderDate = itemDatePicker.minimumDate!
        } else {
            item?.reminderDate = itemDatePicker.date
        }
        
        DataManager.shared.save()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        guard let deleteItem = item else {
          print("Invalid item")
          return
        }
        
        didDeleteItem = true
        DataManager.shared.delete(item: deleteItem)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func setReminderDate(_ sender: Any) {
        if(itemDateSwitch.isOn) {
            itemDatePicker.isHidden = false
            itemDatePicker.date = Date()
        } else {
            itemDatePicker.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let mainVC = presentingViewController as? MainViewController {
            DispatchQueue.main.async {
                if(self.didDeleteItem) {
                    mainVC.items = mainVC.items.filter(){$0 != self.item}
                }
                
                mainVC.tableView.reloadData()
            }
        }
    }
    
}
