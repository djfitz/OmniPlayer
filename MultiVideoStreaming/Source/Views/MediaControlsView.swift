//
//  MediaControlsView.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 7/22/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MediaControlsView: UIView
{

    @IBOutlet var errorLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet var seekTimeSlider: UISlider!

    @IBOutlet var nextButton: UIButton!
    @IBOutlet var play: UIButton!

    @IBOutlet var chromecastButton: GCKUICastButton!
    @IBOutlet var airplayButton: MPVolumeView!

}
