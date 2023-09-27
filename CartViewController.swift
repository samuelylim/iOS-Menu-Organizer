//
//  CartViewController.swift
//  GroupApp
//
//  Created by SAMUEL LIM on 3/9/23.
//

import UIKit

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var orderTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        orderTableView.delegate = self
        orderTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? MenuViewCell else {print("error")
            
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ItemCell")
        }

        let foodItem = Array(order.values)[indexPath.row].0
        cell.food = foodItem
        cell.nameItemOutlet?.text = foodItem.item_name
        cell.caloriesOutlet?.text = "Calories:\(foodItem.calories)"
        cell.counterLabel.text = "\(order[foodItem.item_id]!.1)"
        cell.parentTableView = tableView
        cell.cellIndexPath = indexPath
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
