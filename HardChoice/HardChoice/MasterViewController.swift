//
//  MasterViewController.swift
//  HardChoice
//
//  Created by 杨萧玉 on 14-7-1.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate,CustomIOS7AlertViewDelegate{
    var addAV = CustomIOS7AlertView()
    var modifyAV = CustomIOS7AlertView()
    var managedObjectContext: NSManagedObjectContext? = nil
    var selectedIndexPath:NSIndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let textField = UITextField(frame:CGRectMake(0,0,290,50))
        textField.becomeFirstResponder()
        textField.placeholder = "question"
        textField.keyboardType = .Default
        textField.returnKeyType = .Done
        textField.delegate = self
        addAV.containerView = textField
        addAV.buttonTitles = ["OK","Cancel"]
        addAV.delegate = self
        addAV.useMotionEffects = true
        addAV.show()
        
    }
    
    func modifyObject(indexPath:NSIndexPath){
        let question = self.fetchedResultsController.objectAtIndexPath(indexPath) as Question
        let textField = UITextField(frame:CGRectMake(0,0,290,50))
        textField.becomeFirstResponder()
        textField.placeholder = "question"
        textField.keyboardType = .Default
        textField.returnKeyType = .Done
        textField.delegate = self
        modifyAV.containerView = textField
        modifyAV.buttonTitles = ["OK","Cancel"]
        modifyAV.delegate = self
        modifyAV.useMotionEffects = true
        (modifyAV.containerView as UITextField).text = question.content
        modifyAV.show()
    }
    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as Question
            (segue.destinationViewController as DetailViewController).managedObjectContext = self.managedObjectContext
            (segue.destinationViewController as DetailViewController).detailItem = object
            
        }
    }

    // #pragma mark - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
//        modifyObject(indexPath)
        selectedIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView!, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath!){
        selectedIndexPath = indexPath
        modifyObject(indexPath)
        
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

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as Question
        cell.textLabel.text = object.content
    }

    // #pragma mark - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Question", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "content", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //println("Unresolved error \(error), \(error.userInfo)")
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
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath), atIndexPath: indexPath)
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
            var newManagedObject:Question!
            let av = alertView as CustomIOS7AlertView
            if addAV == av{
                newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name, inManagedObjectContext: context) as Question
            }
            if modifyAV == av{
                newManagedObject = self.fetchedResultsController.objectAtIndexPath(selectedIndexPath) as Question
            }
            // If appropriate, configure the new managed object.
            // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
            newManagedObject.content = (av.containerView as UITextField).text
            
            // Save the context.
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
            alertView.close()
            default:
            alertView.close()
        }
    }
    
    // #pragma mark UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField!){
        let animationDuration:NSTimeInterval  = 1
        var frame = self.view.frame;
        frame.origin.y-=116
        frame.size.height+=116
        self.view.frame = frame;
        UIView.animateWithDuration(animationDuration){
            self.view.frame = frame;
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField!) -> Bool{
        let animationDuration:NSTimeInterval  = 1
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
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

