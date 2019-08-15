//
//  AppDelegate.swift
//  PlayerDemoApp
//
//  Created by Doug Hill on 8/15/19.
//  Copyright © 2019 Doug Hill. All rights reserved.
//

import UIKit
import MultiVideoPlayer

/*
URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"),
URL(string: "http://csm-e.cds1.yospace.com/csm/live/74246610.m3u8"),
URL(string: "http://breaqz.com/movies/Lego911gt3.mov"),
URL(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"),
URL(string: "http://la7-vh.akamaihd.net/i/content/entry/data/0/299/0_b7o9lvba_0_kyyr8vxz_1.mp4/master.m3u8"),
URL(string: "http://cdn-lt-hls-vod.tv2fyn.dk/fhls/p/1966291/sp/196629100/serveFlavor/entryId/0_yct7rqn3/v/2/flavorId/0_h2wfmuqm/name/a.mp4/index.m3u8"),
URL(string: "http://sireclipsfoxru-vh.akamaihd.net/i/mpx/FIC_SIRE_Fox/831/336/Sneak_Peek~~111704~12~21~en~~1_ru_42787397,100_mp4_video_1920x0_4016000_primary_audio_6,099_mp4_video_1280x0_2432000_primary_audio_5,098_mp4_video_1280x0_1800000_primary_audio_4,097_mp4_video_960x0_1200000_primary_audio_3,096_mp4_video_640x0_568000_primary_audio_2,095_mp4_video_480x0_400000_primary_audio_1,.mp4.csmil/index_0_av.m3u8")

*/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        guard let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8") else {return true}
        let item = MediaItem.init(title: "Zelo - Boss Video Productions", url: url)

        MediaPlayerManager.mgr.load(mediaItem: item)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

