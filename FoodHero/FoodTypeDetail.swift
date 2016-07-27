//
//  FoodTypeDetail.swift
//  FoodHero
//
//  Created by Lacie on 6/20/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation

class FoodTypeDetail:UITableViewController {
    var types:[String] = ["Non-Halal", "Halal", "Vegetarian"]
    
    var selectedFood:String? {
        didSet {
            if let food=selectedFood {
                selectedFoodIndex = types.indexOf(food)
            }
        }
    }
    
    var selectedFoodIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodCell", forIndexPath: indexPath)
        cell.textLabel?.text = types[indexPath.row]
    
        if indexPath.row == selectedFoodIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //Other row is selected - need to deselect it
        if let index = selectedFoodIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        selectedFood = types[indexPath.row]
        
        //update the checkmark for the current row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitFoodTypeDetailSegue" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(cell)
                if let index = indexPath?.row {
                    selectedFood = types[index]
                }
            }
        }
    }
}
