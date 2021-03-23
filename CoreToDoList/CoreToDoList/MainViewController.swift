//
//  MainViewController.swift
//  CoreToDoList
//
//  Created by David Kao on 2021-03-21.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var incompleteButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    
    @IBOutlet weak var itemDateSwitch: UISwitch!
    @IBOutlet weak var addItemStackView: UIStackView!
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemNotesTextField: UITextField!
    @IBOutlet weak var itemIsCompletedSwitch: UISwitch!
    @IBOutlet weak var itemDatePicker: UIDatePicker!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var addItemStackViewConstraint: NSLayoutConstraint!
    
    let animateDuration = 0.5
    var items: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        allButton.isSelected = true
        items = DataManager.shared.getAllToDoItems()

        self.tableView.reloadData()

    }
    
    
    @IBAction func setReminderDate(_ sender: Any) {
        if(itemDateSwitch.isOn) {
            itemDatePicker.isHidden = false
            itemDatePicker.date = Date()
        } else {
            itemDatePicker.isHidden = true
        }
        
    }
    @IBSegueAction func openToDoItem(_ coder: NSCoder) -> ToDoItemViewController? {
        let vc = ToDoItemViewController(coder: coder)
        
        guard let indexPath = tableView.indexPathForSelectedRow else {
          return vc
        }
        
        let item = items[indexPath.row]
        vc?.item = item
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        return vc
    }
    
    @IBAction func selectAllFilter(_ sender: Any) {
        setButtonWeight(boldButton: allButton, regularButton1: completeButton, regularButton2: incompleteButton)
        
        items = DataManager.shared.getAllToDoItems()
        
        self.tableView.reloadData()
    }
    
    @IBAction func selectCompleteFilter(_ sender: Any) {
        setButtonWeight(boldButton: completeButton, regularButton1: incompleteButton, regularButton2: allButton)
        
        items = DataManager.shared.getCompletedToDoItems()

        self.tableView.reloadData()
        
    }
    
    @IBAction func selectIncompleteFilter(_ sender: Any) {
        setButtonWeight(boldButton: incompleteButton, regularButton1: completeButton, regularButton2: allButton)
        
        items = DataManager.shared.getIncompleteToDoItems()
        
        self.tableView.reloadData()
        
    }
    
    @IBAction func cancelItem(_ sender: Any) {
        closeAddMenu()
    }
    
    @IBAction func addItem(_ sender: Any) {
        guard var itemTitle = itemTitleTextField.text else {
          print("Invalid title")
          return
        }
        
        guard let itemNotes = itemNotesTextField.text else {
          print("Invalid notes")
          return
        }
        
        if (itemTitle == "") {
            itemTitle = "New Item"
        }
        
        let isCompleted = itemIsCompletedSwitch.isOn
        let needReminderDate = itemDateSwitch.isOn
        
        var date = itemDatePicker.date
        
        if(!needReminderDate) {
            date = itemDatePicker.minimumDate!
        }
        
        let item = DataManager.shared.addToDoItem(title: itemTitle, notes: itemNotes, isCompleted: isCompleted, needReminderDate: needReminderDate, reminderDate: date)
        
        if(completeButton.isSelected && isCompleted) {
            items.append(item)
        } else if(incompleteButton.isSelected && !isCompleted) {
            items.append(item)
        } else if(allButton.isSelected) {
            items.append(item)
        }
        
        tableView.reloadData()
        DataManager.shared.save()
        
        closeAddMenu()
    }
    
    @IBAction func openAddItemStackView(_ sender: Any) {
        hideAllButtons()
        clearItemFields()
        
        addItemStackViewConstraint.constant = 10
        tableViewConstraint.constant = 230
        
        UIView.animate(withDuration: animateDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func closeAddMenu() {
        addItemStackViewConstraint.constant = -300
        tableViewConstraint.constant = 0
        
        UIView.animate(withDuration: animateDuration) {
            self.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animateDuration-0.1) {
            self.showAllButtons()
        }
    }
    
    func hideAllButtons() {
        completeButton.isHidden = true
        incompleteButton.isHidden = true
        allButton.isHidden = true
        addItemButton.isHidden = true
    }
    
    func showAllButtons() {
        completeButton.isHidden = false
        incompleteButton.isHidden = false
        allButton.isHidden = false
        addItemButton.isHidden = false
    }
    
    func clearItemFields() {
        itemTitleTextField.text = nil
        itemNotesTextField.text = nil
        itemIsCompletedSwitch.isOn = false
        itemDateSwitch.isOn = false
        itemDatePicker.date = Date()
    }
    
    func setButtonWeight(boldButton: UIButton, regularButton1: UIButton, regularButton2: UIButton) {
        boldButton.isSelected = true
        regularButton1.isSelected = false
        regularButton2.isSelected = false
        boldButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        regularButton1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        regularButton2.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
    }
    
}

extension MainViewController:UITableViewDataSource {
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
      }
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTableViewCell
    
        let item = items[indexPath.row]
        
        cell.title?.text = item.title
        cell.notes?.text = item.notes
        

        let isCompleted = item.isCompleted
        let needReminderDate = item.needReminderDate
        let date = item.reminderDate!
        cell.needReminderDate = needReminderDate
        cell.isCompleted = isCompleted
        cell.date = date
        if(isCompleted) {
            cell.completedText.isHidden = false
            cell.incompletedText.isHidden = true
        } else {
            cell.incompletedText.isHidden = false
            cell.completedText.isHidden = true
        }
        
        if(!isCompleted && needReminderDate && Date() >= date) {
            cell.passDueText.isHidden = false
        } else {
            cell.passDueText.isHidden = true
        }
        return cell
      }
}

