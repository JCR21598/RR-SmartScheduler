//
//            Author:       Juan Camilo Rdoriguez
//
//      Last Updated:       26 July 2020
//
//       Description:       This ViewController is in charge of the main purpose of the application. That being the usage of the
//                          Round Robin scheduling technique. In addition, this file is has implemented a progressbar for each
//                          task and receiving the content logged in by the used in taskViewController
//

import Foundation
import UIKit


class scheduleViewController: UIViewController {
    
    //  Attributes
    
        // For Shape
    let progressBar = CAShapeLayer()
    let backgroundBar = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    var backgoundBar = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: CGFloat(0), startAngle: +CGFloat.pi/2, endAngle: 2 * CGFloat.pi, clockwise: true)
    var timerBar = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: CGFloat(0), startAngle: +CGFloat.pi/2, endAngle: 2 * CGFloat.pi, clockwise: true)
    
    var timeCirclePercentage = 0.0
    
    
        // Attributes to recieve data from taskViewController
    var finalCycleTasks: [String] = []
    var finalCycleTime: Int = 1
    
        // General attributes
    var currentIndex : Int = 0
    var updateCircle : Double = 1.0
    var count : Double = 0.0
    var timer: Timer!
    let exitAlert = UIAlertController(title: "Tasks Complete", message: nil, preferredStyle: .alert)
    
    
    //  Outlets
    @IBOutlet weak var currentTaskLabel: UILabel!
    @IBOutlet weak var nextTaskLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    
    //  Actions
    
    // Button that removes the current task from the cycle
    @IBAction func taskEndButton(_ sender: UIButton) {
        finalCycleTasks.remove(at: currentIndex)
        
        // Need to perfrom checks once removed item
        
        //  If there is no more tasks to do overall
        if finalCycleTasks.isEmpty{
            self.performSegue(withIdentifier: "unwindReset", sender: self)
            return
        }
        
        //
        if currentIndex == (self.finalCycleTasks.count){
            
            currentIndex -= 1
            nextTaskLabel.text = "Upcoming: \(self.finalCycleTasks[0])"
        }
        //
        else if currentIndex == (self.finalCycleTasks.count - 1){
        
            nextTaskLabel.text = "Upcoming: \(self.finalCycleTasks[0])"
        }
        // If there are no problems with removing the task then continue as normal
        else{
        
            nextTaskLabel.text = "Upcoming: \(self.finalCycleTasks[currentIndex+1])"
        }
        currentTaskLabel.text = (String(finalCycleTasks[self.currentIndex]))
        
        
        count = 0.0
    }
    
    // Button to cancel the whole Round Robin
    @IBAction func dayEndButton(_ sender: UIButton) {
        
        let exitRoundRobinAlert = UIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
        
        exitRoundRobinAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in }))
        exitRoundRobinAlert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { (action) in
            
            // unwind to the previous view - so views do not stack onto each othr
            self.performSegue(withIdentifier: "unwindReset", sender: self)
            
        }))
        
        self.present(exitRoundRobinAlert, animated: true, completion: nil)
    }
    
    
    //  Methods
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // if timer is not terminated - this will terminate timer when changing view
        timer.invalidate()
    }
    
    
    override func viewDidLoad(){
        
        // Initial calls for view
        updatingCircle()
        currentTaskLabel.text = String(finalCycleTasks[self.currentIndex])
        
        // Only when a single task was inputted
        if currentIndex == (self.finalCycleTasks.count - 1){
            nextTaskLabel.text = "Upcoming: End of cycle"
        }
            
        // Any other amount of tasks inputted >= 2
        else{
            nextTaskLabel.text = "Upcoming: \(self.finalCycleTasks[self.currentIndex+1])"
        }
        
        // Gets how long it takes to move a degree in the circle
        updateCircle = (Double(self.finalCycleTime)*60.0)/360.0
        
        // Function "updatingCircle" is called every 0.01 seconds - up until the timer is terminated
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updating), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func updating() {
        
        /// When there is only a task to do on the list
        if finalCycleTasks.count == 1{

            nextTaskLabel.text = "Only this task pending"
            
        }
        
            
        // This is considering there is more than a value in list and have reached end of task time
        if Int(count) >= self.finalCycleTime*60{
            
            /// Reset values
            count = 0.0
            timeCirclePercentage = 0.0
            
            
            if currentIndex + 1 <= finalCycleTasks.count - 1{
                currentIndex += 1
                checkNextTask()
            }
            else{
                currentIndex = 0
                checkNextTask()
            }
            
            currentTaskLabel.text = (String(finalCycleTasks[self.currentIndex]))
            
            return
        }
        
        
        // Time label
        
        /// Display seconds - when <= 60 seconds
        if (finalCycleTime*60)-Int(count) <= 60{
            countDownLabel.text = String((finalCycleTime*60)-Int(count)) + " s"

        }
        /// Display mins - when > 60 seconds
        else{
            countDownLabel.text = String(Int(self.finalCycleTime*60-(Int(count)))/60) + " m"
        }
        
        
        // Update values
        timeCirclePercentage = Double(count)/(Double(self.finalCycleTime)*60.0)
        count += 0.01
        updatingCircle()
    }
    
    
    func checkNextTask(){
        /// Setting for nextTasklabel
        if currentIndex + 1 > finalCycleTasks.count-1{
            
            ///When there is no more tasks to set for upcoming - set back to start
            nextTaskLabel.text = "Upcoming: \(self.finalCycleTasks[0])"
        }
        else{
            ///otherwise set to the next one
            nextTaskLabel.text = "Upcoming: \(self.finalCycleTasks[currentIndex + 1])"
            
        }
    }
    
    // The method that everything to do with the circle seen in the view
    @objc func updatingCircle(){
        
        let width = Double(self.view.frame.width)
        let height = Double(self.view.frame.height)
        var topSafeArea = 0.0
        
        /// To align the cirlce with safeview, instead of view
        if #available(iOS 11.0, *){
            let window = UIApplication.shared.keyWindow
            topSafeArea =  Double((window?.safeAreaInsets.top)!)

        }
        
        // Location of each of the elements 
        countDownLabel.center = CGPoint(x: (width/2), y: (height/4))

        backgoundBar = UIBezierPath(arcCenter: CGPoint(x: width/2, y: (height/4)+topSafeArea), radius: CGFloat(width/4), startAngle: -CGFloat.pi/2,
                                        endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        timerBar = UIBezierPath(arcCenter: CGPoint(x: width/2, y: (height/4)+topSafeArea), radius: CGFloat(width/4), startAngle: -CGFloat.pi/2,
                                      endAngle: CGFloat((timeCirclePercentage*360)-90)*(CGFloat.pi/180), clockwise: true)
        
        // The static bar that indicates that pathing of the dynamic circle
        backgroundBar.path = backgoundBar.cgPath
        backgroundBar.strokeColor = UIColor(red: 0, green: 80/225, blue: 115/225, alpha: 1).cgColor
        backgroundBar.lineWidth = CGFloat(width*0.08)
        backgroundBar.fillColor = UIColor.clear.cgColor

        
        // The dynamic bar
        progressBar.path = timerBar.cgPath
        progressBar.strokeColor = UIColor(red: 238/225, green: 28/225, blue: 37/225, alpha: 1).cgColor
        progressBar.lineWidth = CGFloat(width*0.08)
        progressBar.fillColor = UIColor.clear.cgColor
        progressBar.strokeEnd = 0
        
        view.layer.addSublayer(backgroundBar)
        view.layer.addSublayer(progressBar)
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 0.8
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        progressBar.add(basicAnimation, forKey: "")

    }
}
