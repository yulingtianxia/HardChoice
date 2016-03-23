//
//  DetailViewController.swift
//  HardChoice
//
//  Created by 杨萧玉 on 14-7-1.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

import UIKit
import DataKit
import CoreData

private let rollup = CATransform3DMakeRotation( CGFloat(M_PI_2), CGFloat(0.0), CGFloat(0.7), CGFloat(0.4))

private let rolldown = CATransform3DMakeRotation( CGFloat(-M_PI_2), CGFloat(0.0), CGFloat(0.7), CGFloat(0.4))

class DetailViewController: UITableViewController, NSFetchedResultsControllerDelegate ,UITextFieldDelegate{
    var managedObjectContext: NSManagedObjectContext? = nil
    var selectedIndexPath:NSIndexPath!
    var lastVisualRow = 0
    var detailItem: Question! {
        didSet {
            // Update the view.
            
        }
    }
    var wormhole:Wormhole!
    let headerBtn = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 50))
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableFooterView = UIView()
        headerBtn.setTitle(NSLocalizedString("Reset Weight",comment:""), forState: UIControlState.Normal)
        headerBtn.backgroundColor = UIColor.redColor()
        headerBtn.addTarget(self, action: #selector(DetailViewController.resetWeight(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        tableView.tableHeaderView = headerBtn
        navigationController?.hidesBarsOnSwipe = true
        
        //初始化虫洞
        wormhole = Wormhole(applicationGroupIdentifier: appGroupIdentifier, optionalDirectory: "wormhole")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            
            let count = self.fetchedResultsController.fetchedObjects!.count
            var arr = fetchedResultsController.fetchedObjects!
            var sum:Int = 0
            for object : AnyObject in arr{
                sum += (object as! Choice).weight.integerValue
            }
            if sum>0{
                var lucknum = arc4random()%UInt32(sum)+1
                var num = 0
                var n:UInt32 = 0
                while lucknum>0{
                    n = UInt32((arr[num] as! Choice).weight.integerValue)
                    if lucknum <= n{
                        break
                    }
                    else{
                        lucknum-=n
                        num += 1
                        if num>=count{
                            num -= 1
                            break
                        }
                    }
                }
                let message = (arr[num] as! Choice).name
                wormhole.passMessageObject([detailItem.content, message], identifier: "shake")
                //弹出Alert
                let alertView = UIAlertView()
                alertView.alertViewStyle = .Default
                alertView.title = NSLocalizedString("Congratulations",comment:"")
                alertView.message = message
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }  
        }
    }
    
    // MARK: - target-action
    func resetWeight(sender: AnyObject) {
        // Create Entity Description
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Choice")
        
        //show AlertController
        let title = NSLocalizedString("Reset Weight",comment:"")
        let message = NSLocalizedString("Enter the weight you want to reset", comment: "")
        let okbtn = NSLocalizedString("OK",comment:"")
        let cancelbtn = NSLocalizedString("Cancel",comment:"")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: okbtn, style: .Destructive) { [unowned self] (action) -> Void  in
            
            // Configure Batch Update Request
            batchUpdateRequest.resultType = .UpdatedObjectIDsResultType
            batchUpdateRequest.propertiesToUpdate = ["weight":Int(alert.textFields?[0].text ?? "1") ?? 1]
            //        batchUpdateRequest.affectedStores = []
            //        batchUpdateRequest.predicate = ...
            
            // Execute Batch Request
            
            do {
                let batchUpdateResult = try self.managedObjectContext?.executeRequest(batchUpdateRequest) as! NSBatchUpdateResult
                // Extract Object IDs
                
                let objectIDs = batchUpdateResult.result as! [NSManagedObjectID]
                
                for objectID in objectIDs {
                    // Turn Managed Objects into Faults
                    print(objectID)
                    if let managedObject = self.managedObjectContext?.objectWithID(objectID) {
                        self.managedObjectContext?.performBlock({ () -> Void in
                            self.managedObjectContext?.refreshObject(managedObject, mergeChanges: false)
                        })
                    }
                }
                // Perform Fetch
                try self.fetchedResultsController.performFetch()
            } catch let batchUpdateRequestError as NSError {
                print("Unable to execute batch update request.")
                print("\(batchUpdateRequestError)\(batchUpdateRequestError.localizedDescription)")
            } catch {
                print("reset weight error")
            }
        }
        let cancelAction = UIAlertAction(title: cancelbtn, style: .Cancel) { (action) -> Void in
            
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextFieldWithConfigurationHandler { (weightTF) -> Void in
            weightTF.borderStyle = .None
            weightTF.keyboardType = .NumberPad
            weightTF.placeholder = NSLocalizedString("Weight can only be an integer",comment:"")
            weightTF.delegate = self
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func insertNewObject(sender: AnyObject) {
        showEditAlertWithInsert(true)
    }
    
    //  MARK: - Segues
    //
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "showDetail" {
    //            let indexPath = self.tableView.indexPathForSelectedRow()
    //            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as Choice
    //            (segue.destinationViewController as DetailViewController).detailItem = object
    //        }
    //    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceCell", forIndexPath: indexPath) as! DynamicCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedIndexPath = indexPath
        showEditAlertWithInsert(false)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    /**
    configureCell
    
    - parameter cell:      cell be configured
    - parameter indexPath: Data with indexPath you want to configured
    */
    func configureCell(cell: DynamicCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Choice
        cell.textLabel!.text = object.name
        cell.detailTextLabel!.text = "\(object.weight)"
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //1. Setup the CATransform3D structure

        if lastVisualRow <= indexPath.row {//roll up
            cell.layer.transform = rollup
        }
        else{//roll down
            cell.layer.transform = rolldown
        }
        lastVisualRow = indexPath.row
        
        
        //2. Define the initial state (Before the animation)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.alpha = 0
        cell.layer.anchorPoint = CGPointMake(0, 0.5)
        cell.layer.position.x = 0
        
        //3. Define the final state (After the animation) and commit the animation
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1
            cell.layer.shadowOffset = CGSizeMake(0, 0)
        })
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
            }
            
            let fetchRequest = NSFetchRequest()
            // Edit the entity name as appropriate.
            let entity = NSEntityDescription.entityForName("Choice", inManagedObjectContext: self.managedObjectContext!)
            fetchRequest.entity = entity
            
            fetchRequest.predicate = NSPredicate(format:"question.content='\(detailItem!.content)'")
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        
            do {
                try _fetchedResultsController!.performFetch()
            } catch {
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
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! DynamicCell, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        wormhole.passMessageObject(true, identifier: "choiceData")
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField){
        
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool{
        textField.resignFirstResponder();
        return true
    }
    
    func showEditAlertWithInsert(isNew:Bool){
        let title = NSLocalizedString("Enter Choices of the Trouble",comment:"")
        let message = detailItem?.content
        let okbtn = NSLocalizedString("OK",comment:"")
        let cancelbtn = NSLocalizedString("Cancel",comment:"")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: okbtn, style: .Destructive) { [unowned self](action) -> Void in
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity
            var newManagedObject:Choice!
            if isNew{
                newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context) as! Choice
            }
            else{
                newManagedObject = self.fetchedResultsController.objectAtIndexPath(self.selectedIndexPath) as! Choice
            }
            // If appropriate, configure the new managed object.
            // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
            
            newManagedObject.name = (alert.textFields?.first?.text!)!
            if let weight = Int((alert.textFields?[1].text!)!){
                newManagedObject.weight = weight
            }
            self.detailItem!.choices = self.detailItem!.choices.setByAddingObject(newManagedObject)
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
        let cancelAction = UIAlertAction(title: cancelbtn, style: .Cancel) { (action) -> Void in
            
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextFieldWithConfigurationHandler { (choiceNameTF) -> Void in
            if !isNew {
                let choice = self.fetchedResultsController.objectAtIndexPath(self.selectedIndexPath) as! Choice
                choiceNameTF.text = choice.name
            }
            choiceNameTF.borderStyle = .None
            choiceNameTF.placeholder = NSLocalizedString("An answer of your trouble",comment:"")
            choiceNameTF.delegate = self
            choiceNameTF.becomeFirstResponder()
            
        }
        alert.addTextFieldWithConfigurationHandler { (choiceWeightTF) -> Void in
            if !isNew {
                let choice = self.fetchedResultsController.objectAtIndexPath(self.selectedIndexPath) as! Choice
                choiceWeightTF.text = "\(choice.weight)"
            }
            choiceWeightTF.borderStyle = .None
            choiceWeightTF.keyboardType = .NumberPad
            choiceWeightTF.placeholder = NSLocalizedString("Weight can only be an integer",comment:"")
            choiceWeightTF.delegate = self
            
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

