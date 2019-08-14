//
//  MediaHomeTableViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 8/8/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit
import MultiVideoPlayer

class MediaHomeTableViewController: UITableViewController
{
    static let mediaURLs =
        [
            URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
            URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
            URL(string: "http://csm-e.cds1.yospace.com/csm/live/74246610.m3u8"),
            URL(string: "http://breaqz.com/movies/Lego911gt3.mov"),
            URL(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"),
            URL(string: "http://la7-vh.akamaihd.net/i/content/entry/data/0/299/0_b7o9lvba_0_kyyr8vxz_1.mp4/master.m3u8"),
            URL(string: "http://cdn-lt-hls-vod.tv2fyn.dk/fhls/p/1966291/sp/196629100/serveFlavor/entryId/0_yct7rqn3/v/2/flavorId/0_h2wfmuqm/name/a.mp4/index.m3u8"),
            URL(string: "http://sireclipsfoxru-vh.akamaihd.net/i/mpx/FIC_SIRE_Fox/831/336/Sneak_Peek~~111704~12~21~en~~1_ru_42787397,100_mp4_video_1920x0_4016000_primary_audio_6,099_mp4_video_1280x0_2432000_primary_audio_5,098_mp4_video_1280x0_1800000_primary_audio_4,097_mp4_video_960x0_1200000_primary_audio_3,096_mp4_video_640x0_568000_primary_audio_2,095_mp4_video_480x0_400000_primary_audio_1,.mp4.csmil/index_0_av.m3u8")
        ]
    override func viewDidLoad()
    {
        super.viewDidLoad()

        MediaPlayerManager.mgr.avFoundationPlayer.beginSearchForRemoteDevices()
        MediaPlayerManager.mgr.chromecastPlayer.beginSearchForRemoteDevices()
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
