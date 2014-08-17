//
//  DetailViewController.swift
//  HardChoice
//
//  Created by 杨萧玉 on 14-7-1.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, NSFetchedResultsControllerDelegate ,CustomIOS7AlertViewDelegate,UITextFieldDelegate{
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var addAV = CustomIOS7AlertView()
    var modifyAV = CustomIOS7AlertView()
    var selectedIndexPath:NSIndexPath!
    var detailItem: Question? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: Question = self.detailItem {
            let container = ChoiceView(frame:CGRectMake(0,0,290,100))
            container.setDelegate(self)
            
            addAV.containerView = container
            addAV.buttonTitles = ["OK","Cancel"]
            addAV.delegate = self
            addAV.useMotionEffects = true
            modifyAV.containerView = container
            modifyAV.buttonTitles = ["OK","Cancel"]
            modifyAV.delegate = self
            modifyAV.useMotionEffects = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent!) {
        if motion == .MotionShake{
            
            let count = self.fetchedResultsController.fetchedObjects.count
            var arr = fetchedResultsController.fetchedObjects
            var sum:Int = 0
            for object : AnyObject in arr{
                sum+=(object as Choice).weight.integerValue
            }
            if sum>0{
                var lucknum = arc4random()%UInt32(sum)
//                println("\(lucknum)")
                var num = 0
                var n:UInt32 = 0
                while lucknum>0{
                    if lucknum <= n{
                        break
                    }
                    else{
                        num++
                        lucknum-=n
                        if num>=count{
                            break
                        }
                        n = UInt32((arr[num] as Choice).weight.integerValue)
                    }
                }
//                println("\(num)")
                var alertView = UIAlertView()
                alertView.alertViewStyle = .Default
                alertView.title = "恭喜"
                alertView.message = "\(detailItem!.content)的答案是：\n\((arr[num] as Choice).name)"
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
            
        }
    }
    @IBAction func insertNewObject(sender: AnyObject) {
        addAV.show()
    }
    
//    // #pragma mark - Segues
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDetail" {
//            let indexPath = self.tableView.indexPathForSelectedRow()
//            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as Choice
//            (segue.destinationViewController as DetailViewController).detailItem = object
//        }
//    }
    
    // #pragma mark - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceCell", forIndexPath: indexPath) as DynamicCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        selectedIndexPath = indexPath
        let choice = self.fetchedResultsController.objectAtIndexPath(indexPath) as Choice
        (modifyAV.containerView as ChoiceView).nameTF.text = choice.name
        (modifyAV.containerView as ChoiceView).weightTF.text = "\(choice.weight)"
        modifyAV.show()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
            
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    func configureCell(cell: DynamicCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as Choice
        cell.textLabel.text = object.name
        cell.detailTextLabel.text = "\(object.weight)"
    }
    
    // #pragma mark - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
        return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Choice", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity

        fetchRequest.predicate = NSPredicate(format:"question.content='\(detailItem!.content)'")
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            println("Unresolved error \(error!), \(error!.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath) as DynamicCell, atIndexPath: indexPath)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    // #pragma mark CustomIOS7AlertViewDelegate
    
    func customIOS7dialogButtonTouchUpInside(alertView:AnyObject!, clickedButtonAtIndex buttonIndex:Int){
        switch buttonIndex{
        case 0:
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity
            var newManagedObject:Choice!
            let av = alertView as CustomIOS7AlertView
            if addAV == av{
                newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name, inManagedObjectContext: context) as Choice
            }
            if modifyAV == av{
                newManagedObject = self.fetchedResultsController.objectAtIndexPath(selectedIndexPath) as Choice
            }
            // If appropriate, configure the new managed object.
            // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
            
            newManagedObject.name = (av.containerView as ChoiceView).nameTF.text
            
            
            if let weight = (av.containerView as ChoiceView).weightTF.text.toInt()?{
                newManagedObject.weight = weight
            }
            
            detailItem!.addChoicesObject(newManagedObject)
            
            // Save the context.
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                println("Unresolved error \(error!), \(error!.userInfo)")
//                abort()
            }
            alertView.close()
        default:
            alertView.close()
        }
        self.configureView()
    }
    
    
    // #pragma mark UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField!){
        let animationDuration:NSTimeInterval  = 0.30
        var frame = self.view.frame;
        frame.origin.y-=116
        frame.size.height+=116
        self.view.frame = frame;
        UIView.animateWithDuration(animationDuration){
            self.view.frame = frame;
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField!) -> Bool{
        let animationDuration:NSTimeInterval  = 0.30
        var frame = self.view.frame;
        frame.origin.y+=116;
        frame.size.height-=116;
        self.view.frame = frame;
        //self.view移回原位置
        UIView.animateWithDuration(animationDuration){
            self.view.frame = frame;
        }
        textField.resignFirstResponder();
        return true
    }

}

