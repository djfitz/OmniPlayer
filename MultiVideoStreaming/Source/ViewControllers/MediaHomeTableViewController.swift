//
//  MediaHomeTableViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 8/8/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit

class MediaHomeTableViewController: UITableViewController
{
    static let mediaURLs =
        [
            URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
            URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
            URL(string: "http://csm-e.cds1.yospace.com/csm/live/74246610.m3u8"),
            URL(string: "http://breaqz.com/movies/Lego911gt3.mov"),
            URL(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8")
        ]
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    //
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//
//    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let selectedCell = self.tableView.indexPathForSelectedRow
        {
            let row = selectedCell.row
            let mediaURLForRow = MediaHomeTableViewController.mediaURLs[row]

            if let destVC = segue.destination as? ViewController
            {
                destVC.mediaURL = mediaURLForRow
            }
        }
    }

}
