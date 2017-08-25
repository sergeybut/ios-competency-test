//
//  MasterViewController.swift
//  TestApp
//
//  Created by sergey on 8/25/17.
//  Copyright © 2017 sergey. All rights reserved.
//

import UIKit
import AlamofireImage

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var friends = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        friendsList();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = friends[indexPath.row] as! NSDictionary
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendTableViewCell

        let object = friends[indexPath.row] as! NSDictionary
        let first_name = object["first_name"] as! NSString
        let last_name = object["last_name"] as! NSString
        let fullName = "\(first_name) \(last_name)"
        cell.fullNameLabel.text = fullName
        cell.statusLabel.text = object["status"] as? String
        
        let urlForImage = NSURL(string: (object["img"] as! NSString) as String)
        
        cell.friendImage.af_setImage(
            withURL: urlForImage! as URL,
            placeholderImage: nil,
            filter: nil
        )
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // MARK: - API Stuff
    
    func friendsList() {
        FriendsMOC.request(.friendsList) { result in
            do {
                let response = try result.dematerialize()
                let value = try response.mapNSArray()
                self.friends = value;
                self.tableView.reloadData()
            } catch {
                print("Enable to reach friendsList, error: \(error)")
            }
        }
    }
}

