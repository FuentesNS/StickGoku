//
//  Defined.swift
//  StickGoku
//
//  Created by MacBookMBA1 on 18/10/22.
//

import Foundation

let DefinedScreenWidth:CGFloat = 1536
let DefinedScreenHeight:CGFloat = 2048

enum StickGokuGameSceneChildName: String{
    case GokuName = "hero"
    case StickName = "stick"
    case StackName = "stack"
    case StackMidName = "stack_mid"
    case ScoreName = "score"
    case TipName = "tip"
    case PerfectName = "perfect"
    case GameOverLayerName = "over"
    case RetryButtonName = "retry"
    case HighScoreName = "highscore"
}

enum StickGokuGameSceneActionKey: String{
    case WalkAction = "Walk"
    case StickGrowAudioAction = "" // name sound
    case StickGrowAction = "stick_grow"
    case GokuScaleAction = "goku_scale"
}

enum StickGokuGameSceneEffectAudioName: String{
    case DeadAudioName = "dead.wav"
    case StickGrowAudioName = "stick_grow_loop.wav"
    case StickGrowOverAudioName = "kick.wav"
    case StickFallAudioName = "fall.wav"
    case StickTouchMidAudioName = "touch_mid.wav"
    case VictoryAudioName = "victory.wav"
    case HighScoreAudioName = "highScore.wav"
}

enum StickGokuGameSceneZPosition: CGFloat{
    case BackgroundZPosition = 0
    case StackZPosition = 30
    case StackMidZPosition = 35
    case StickZPostion = 40
    case ScroeBackgroundZPosition = 50
    case GokuZPosition, ScoreZPosition, TipZPosition, PerfectZPostion = 100
    case EmitterZPosition
    case GameOverZPosition
}
