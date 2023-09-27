//
//  MenuViewCell.swift
//  GroupApp
//
//  Created by SAMUEL LIM on 2/28/23.
//

import UIKit

class MenuViewCell: UITableViewCell {
  
    @IBOutlet weak var nameItemOutlet: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var caloriesOutlet: UILabel!
    
    @IBOutlet weak var servingsInput: UITextField!
    
    weak var parentTableView: UITableView?
    
    var cellIndexPath: IndexPath?
    
    var addedToCart = false
    var food: foodItem!
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBAction func stepperChanged(_ sender: UIStepper) {
        if(sender.value == 0){
            order[food.item_id] = nil
            counterLabel.text = "0"
        } else{
            order[food.item_id] = (food,Int(sender.value))
            counterLabel.text = "\(sender.value)"
        }
        print(order)
        
        
        
    }
}
