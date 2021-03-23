//
//  MyTableViewCell.swift
//  CoreToDoList
//
//  Created by David Kao on 2021-03-22.
//
import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var notes: UILabel!
    var date: Date = Date()
    var isCompleted: Bool = false
    var needReminderDate: Bool = false
    
    @IBOutlet weak var completedText: UILabel!
    @IBOutlet weak var incompletedText: UILabel!
    
    @IBOutlet weak var passDueText: UILabel!
}
