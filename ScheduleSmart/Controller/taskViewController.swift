//
//            Author:       Juan Camilo Rdoriguez
//
//      Last Updated:       26 July 2020
//
//       Description:       This main purposese of taskViewController are:
//
//                              - The TableView, for the user to be able to input the tasks they would want to complete.
//
//                              - The time set, the slider which the user can intereact with to set the time quantum for each Round
//                                Robin cycle
//
//                          These two critical pieces of information from the user are then sent to scheduleViewController
//

import Foundation
import UIKit

class taskViewController: UIViewController{
    
    //  Attributes
    var taskList: [String] = []     /// List where tasks from the user will be stored
    
    
    //  Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var newTaskTextField: UITextField!
    
    
    //  Actions
    
    /// Button to start thr Round Robin
    @IBAction func startButton(_ sender: UIButton) {
        
        /// If no time is not set
        if timeLabel.text == "Time in mins"{
            alert(title: "No time allocated", message: "Please set a time for your taks using the slider")
        }
        /// If no tasks are set
        else if taskList.isEmpty{
            alert(title: "No task set", message: "Please enter the task you would like to compleate")
        }
        /// If tasks and time are set then start
        else{
            self.performSegue(withIdentifier: "startTasks", sender: self)
        }
        
    }
    
    /// Insert task to tableView
    @IBAction func addNewTaskButton(_ sender: UIButton) {
        insertNewTask()
    }
    
    /// set lable according to slider
    @IBAction func timeSlider(_ sender: UISlider) {
        
        timeLabel.text = String(Int(sender.value))
    }
    
    
    
    //  Methods
    override func viewDidLoad(){
        super.viewDidLoad()
        
        taskList = []       ///  Meant mainly to reset when view is called again
        taskTableView.reloadData()
        
        // No unnecessary cells for TableView
        taskTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        // Setting & Formatting the Date
        let currentDate = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let dateString = formatter.string(from: currentDate)
        
        dateLabel.text = dateString
    }
    
    // Passing the data set by the user over the segue - tasks and time
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        // to be able to access attributes from scheduleViewController
        let vc = segue.destination as! scheduleViewController
        
        // settings those attributes from other viewcontroller to the values obtained on this view
        vc.finalCycleTasks = taskList
        vc.finalCycleTime = Int(timeLabel.text!)!
        
    }
    
    
    func insertNewTask(){
        
        // When add is clicked it adds to list
        taskList.append(newTaskTextField.text!)
        let indexPath = IndexPath(row:taskList.count-1, section: 0)
        
        // Animation to add task to the TableView
        taskTableView.beginUpdates()
        taskTableView.insertRows(at: [indexPath], with: .automatic)
        taskTableView.endUpdates()
        
        // Clear up once task has been added
        newTaskTextField.text = ""
        view.endEditing(true)
    
    }
    
    // To be able to go to previous views
    @IBAction func unwindReset(_ sender: UIStoryboardSegue){ //Return to main menu function
        self.viewDidLoad()
    }
    
    
    // Alert the user about certain actions
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}



// This extension is for the TableView
extension taskViewController:UITableViewDataSource, UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    // Linking to prototype cell on stroyboard
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableTaskCell", for: indexPath)
        
        cell.textLabel!.text = taskList[indexPath.row]
        
        return cell
        
    }
    
    // Allow editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Configure the editing features
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // For deleting tasks item on the tableView
        if editingStyle == .delete{
            
            // Delete content from list
            taskList.remove(at: indexPath.row)
            
            //Animation to remoce task frm TableView
            taskTableView.beginUpdates()
            taskTableView.deleteRows(at: [indexPath], with: .automatic)
            taskTableView.endUpdates()
            
        }
        
    }
    
}
