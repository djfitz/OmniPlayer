//
//  ViewUpdates.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 10/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import Foundation

/**
    A protocol for updating a view based on Media Player messages.

    This protocol allows the audio engine to manage a UI widget
    state, based on client-supplied standard controls.
    For example, the protocol has properties for a play button and
    a pause button. A UI client can create and style any view that
    uses standard UIButtons, the audio engine can then update those
    buttons based on state changes. This relieves the client app
    from having to manage these complicated state changesin the UI
    themselves.
*/
protocol MediaPlayerUIDelegate {
    /**
     When the media is playing, the Play button is hidden.
     When the media is paused, tapping the play button will
     send a Play message to the audio engine.
     */
    var PlayButton:UIButton {get}

    /**
     When the media is paused, the Pause button is hidden.
     When the media is playing, tapping the Pause button will
     send a pause message to the audio engine.
     */
    var PauseButton:UIButton {get}

    /**
     A slider that will show time elapsed and time remaining.

     The UI controller receives updates for the current time
     from the audio engine and updates the progress on the the slider.

     The UI controller also handles gesture messages for the slider,
     and sends messages to the audio engine. For example, dragging
     the slider will perform a seek on the audio engine.
    */
    var timeSlider: UISlider {get}

}
