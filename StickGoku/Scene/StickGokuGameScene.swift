//
//  StickGokuGameScene.swift
//  StickGoku
//
//  Created by MacBookMBA1 on 19/10/22.
//

import Foundation
import SpriteKit


class StickGokuGameScene: SKScene, SKPhysicsContactDelegate{
    
    let StoreScoreName = "com.stickGoku.score"
    
    let StackHeight: CGFloat = 400.0
    let StackMaxWidth: CGFloat = 300.0
    let StackMinWidth: CGFloat = 100.0
    let Gravity: CGFloat = -100.0
    let StackGapMinWitth: Int = 80
    let GokuSpeed: CGFloat = 760
    
    var NextLeftStartX: CGFloat = 0
    var StickHeigt: CGFloat = 0
    
    var IsBegin = false
    var IsEnd = false
    var LeftStack: SKShapeNode?
    var RightStack: SKShapeNode?
    
    
    struct GAP {
        static let XGAP: CGFloat = 20
        static let YGAP: CGFloat = 4
    }
    
    var GameOver = false{
        willSet {
            if newValue {
                CheckHighScoreAndStore()
                let gameOverLayer = childNode(withName: StickGokuGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
                gameOverLayer?.run(SKAction.MoveDistance(CGVector(dx: 0, dy: 100), fadeInWithDuration: 0.2))
            }
        }
    }
    
    var Score : Int = 0{
        willSet{
            let scoreBand = childNode(withName: StickGokuGameSceneChildName.ScoreName.rawValue) as! SKLabelNode
            scoreBand.text = "\(newValue)"
            scoreBand.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.5), SKAction.scale(to: 1, duration: 0.1)]))
            
            if newValue == 1{
                
            }
        }
    }
    
    
    lazy var PlayAbleRect: CGRect = {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let maxAspectRatioWith = self.size.height / maxAspectRatio
        let palyAbleMargin = (self.size.width - maxAspectRatio)
        return CGRect(x: palyAbleMargin, y: 0, width: maxAspectRatioWith, height: self.size.height)
    }()
    
    
    lazy var WalkAction: SKAction = {
        var textures: [SKTexture] = []
        for i in 0...7{
            let texture = SKTexture(imageNamed: "Goku\(i + 1).png")
            textures.append(texture)
        }
        
        let action = SKAction.animate(with: textures, timePerFrame: 0.5,  resize: true, restore: true)
        
        return SKAction.repeatForever(action)
    }()
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
    }

    
    //MARK: - Override Method
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !GameOver else{
            let GameOverLayer = childNode(withName: StickGokuGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
            
            let location = touches.first?.location(in: GameOverLayer!)
            let retry = GameOverLayer!.atPoint(location!)
            
            if retry.name == StickGokuGameSceneChildName.RetryButtonName.rawValue{
                retry.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "button_rety_down"), resize: false), SKAction.wait(forDuration: 0.3)]), completion: {[unowned self] () -> Void in
                    self.Restart()
                    
                })
            }
            return
        }
        
        if !IsBegin && !IsEnd{
            IsBegin = true
            
            let stick = LoadStick()
            let goku = childNode(withName: StickGokuGameSceneChildName.GokuName.rawValue) as! SKSpriteNode
            
            let action = SKAction.resize(toHeight: CGFloat(DefinedScreenHeight - StackHeight), duration: 1.5)
            stick.run(action, withKey: StickGokuGameSceneActionKey.StickGrowAction.rawValue)
            
            let scaleAction = SKAction.sequence([SKAction.scaleY(to: 0.9, duration: 0.05), SKAction.scaleY(to: 1, duration: 0.05)])
            let loopAction = SKAction.group([SKAction.playSoundFileNamed(StickGokuGameSceneEffectAudioName.StickGrowAudioName.rawValue, waitForCompletion: true)])
            
            stick.run(SKAction.repeatForever(loopAction), withKey: StickGokuGameSceneActionKey.StickGrowAction.rawValue)
            goku.run(SKAction.repeatForever(scaleAction), withKey: StickGokuGameSceneActionKey.GokuScaleAction.rawValue)
            
            return
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !IsBegin && !IsEnd{
            IsEnd = true
            
            let goku = childNode(withName: StickGokuGameSceneChildName.GokuName.rawValue) as! SKSpriteNode
            goku.removeAction(forKey: StickGokuGameSceneActionKey.GokuScaleAction.rawValue)
            goku.run(SKAction.scale(to: 1, duration: 0.04))
            
            let stick = childNode(withName: StickGokuGameSceneChildName.StackName.rawValue) as! SKSpriteNode
            stick.removeAction(forKey: StickGokuGameSceneActionKey.StickGrowAction.rawValue)
            stick.run(SKAction.playSoundFileNamed(StickGokuGameSceneEffectAudioName.StickGrowAudioName.rawValue, waitForCompletion: false))
            
            StickHeigt = stick.size.height
            
            let action = SKAction.rotate(toAngle: CGFloat(-Double.pi / 2), duration: 0.4, shortestUnitArc: true)
            let playFall = SKAction.playSoundFileNamed(StickGokuGameSceneEffectAudioName.StickFallAudioName.rawValue, waitForCompletion: false)
            
            stick.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), action, playFall]), completion: {[unowned self] () -> Void in
                self.GokuGo(self.CheckPass())
            })
        }
    }
    
    
    
    
    func Start(){
        LoadBackGround()
        LoadScoreBackGround()
        LoadScore()
        LoadTip()
        LoadGameOverLayer()
        
        LeftStack = LoadStacks(false, startLeftPoint: PlayAbleRect.origin.x)
        self.RemoveMidTouch(false, left: true)
        LoadGoku()
        
        let maxGap = Int(PlayAbleRect.width - StackHeight -
                         (LeftStack?.frame.size.width)!)
        
        let gap = CGFloat(RandomInRange(StackGapMinWitth...maxGap))
        RightStack = LoadStacks(false, startLeftPoint: NextLeftStartX + gap)
        
        GameOver = false
    }
    
    
    
    
    func Restart(){
        IsBegin = false
        IsEnd = false
        Score = 0
        NextLeftStartX = 0
        removeAllChildren()
        Start()
    }
    
    
    
    
    fileprivate func CheckPass() -> Bool{
        let stick = childNode(withName: StickGokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        
        let rightPoint = DefinedScreenWidth / 2 + stick.position.x + self.StickHeigt
        
        guard rightPoint < self.NextLeftStartX else {
            return false
        }
        
        guard ((LeftStack?.frame)!.intersects(stick.frame) && (RightStack?.frame)!.intersects(stick.frame)) else {
            return false
        }
        
        self.CheckTouchMidStack()
        return true
    }
    
    
    fileprivate func CheckTouchMidStack(){
        let stick = childNode(withName: StickGokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        let stacktMid = RightStack!.childNode(withName: StickGokuGameSceneChildName.StackMidName.rawValue) as! SKShapeNode
        
        let newPoint = stacktMid.convert(CGPoint(x: -10, y: 10), to: self)
        
        if ((stick.position.x + self.StickHeigt) >= newPoint.x &&
            (stick.position.x + self.StickHeigt) <= newPoint.x +
            20){
            LoadPerfect()
            self.run(SKAction.playSoundFileNamed(StickGokuGameSceneEffectAudioName.StickTouchMidAudioName.rawValue, waitForCompletion: false))
            Score += 1
        }
    }
    
    
    
    fileprivate func RemoveMidTouch(_ animate: Bool, left:Bool){
        let stack = left ? LeftStack: RightStack
        let mid = stack!.childNode(withName: StickGokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        
        if animate {
            mid.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        }else{
            mid.removeFromParent()
        }
    }
    
    
    fileprivate func GokuGo(_ pass: Bool){
        let Goku = childNode(withName: StickGokuGameSceneChildName.StickName.rawValue) as!
        SKSpriteNode
        
        guard pass else{
            
            let stick = childNode(withName: StickGokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
            
            let dis: CGFloat = stick.position.x + self.StickHeigt
            
            let overGap = DefinedScreenWidth / 2 - abs(Goku.position.x)
            let disGap = NextLeftStartX - overGap - (RightStack?.frame.size.width)! / 2
            
            let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / GokuSpeed)))
            
            Goku.run(WalkAction, withKey: StickGokuGameSceneActionKey.WalkAction.rawValue)
            Goku.run(move, completion: {[unowned self] () -> Void in
                stick.run(SKAction.rotate(toAngle: CGFloat(-Double.pi), duration: 0.4))
                
                //physicsBody actualiza cuando un nodo no esta participando en la ejecucion de las fisicas
                Goku.physicsBody!.affectedByGravity = true
                //(PlaySoundFileNamed) Asigna el sonido cuando el personaje muere
                Goku.run(SKAction.playSoundFileNamed(StickGokuGameSceneEffectAudioName.DeadAudioName.rawValue, waitForCompletion: false))
                Goku.removeAction(forKey: StickGokuGameSceneActionKey.WalkAction.rawValue)
                self.run(SKAction.wait(forDuration: 0.5), completion: {[unowned self] ( ) -> Void in
                    self.GameOver = true
                })
            })
            return
        }
        let dis: CGFloat = NextLeftStartX - DefinedScreenWidth / 2 - Goku.size.width / 2 - GAP.XGAP
        
        let overGap = DefinedScreenWidth  / 2 - abs (Goku.position.x)
        let disGap = NextLeftStartX - overGap - (RightStack?.frame.size.width)! / 2
        
        let move = SKAction.moveTo(x: dis, duration: (abs(disGap / GokuSpeed)))
        
        Goku.run(WalkAction, withKey: StickGokuGameSceneActionKey.WalkAction.rawValue)
        Goku.run(move, completion: {[unowned self]() -> Void in self.Score += 1
            
            Goku.run(SKAction.playSoundFileNamed(StickGokuGameSceneEffectAudioName.VictoryAudioName.rawValue, waitForCompletion: false))
            Goku.removeAction(forKey: StickGokuGameSceneActionKey.WalkAction.rawValue)
            self.MoveStackAndCreateNew()
        })
    }
    
    
    fileprivate func CheckHighScoreAndStore(){
        let highScore = UserDefaults.standard.integer(forKey: StoreScoreName)
        if Score > Int(highScore){
            ShowHighScore()
            
            UserDefaults.standard.set(Score, forKey: StoreScoreName)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    fileprivate func ShowHighScore(){
        self.run(SKAction.playSoundFileNamed(StickGokuGameSceneEffectAudioName.HighScoreAudioName.rawValue, waitForCompletion: false))
        
        let wait = SKAction.wait(forDuration: 0.4)
        let grow = SKAction.scale(to: 1.5, duration: 0.4)
        grow.timingMode = .easeInEaseOut
        let explosion = StarEmitterActionAtPosition(CGPoint(x: 0, y: 300))
        let shrink = SKAction.scale(to: 1, duration: 0.2)
        
        let idleGrow = SKAction.scale(to: 1.2, duration: 0.4)
        idleGrow.timingMode = .easeInEaseOut
        let idleShrink = SKAction.scale(to: 1, duration: 0.4)
        
        let pulsate = SKAction.repeatForever(SKAction.sequence([idleGrow, idleShrink]))
        
        let gameOverLayer = childNode(withName: StickGokuGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
        let highScoreLabel = gameOverLayer?.childNode(withName: StickGokuGameSceneChildName.HighScoreName.rawValue) as SKNode?
        highScoreLabel?.run(SKAction.sequence([wait, explosion, grow, shrink]), completion: {() -> Void in highScoreLabel?.run(pulsate)
            
        })
    }
    
    
    fileprivate func MoveStackAndCreateNew(){
        let action = SKAction.move(by: CGVector(dx: -NextLeftStartX + (RightStack?.frame.size.width)! + PlayAbleRect.origin.x - 2, dy: 0), duration: 0.3)
        RightStack?.run(action)
        self.RemoveMidTouch(true, left:false)
        
        let goku = childNode(withName: StickGokuGameSceneChildName.GokuName.rawValue) as! SKSpriteNode
        let stick = childNode(withName: StickGokuGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        
        goku.run(action)
        stick.run(SKAction.group([SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), SKAction.fadeAlpha(to: 0, duration: 0.3)]), completion: {() ->  Void in stick.removeFromParent()
            
        })
        
        LeftStack?.run(SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), completion: {[unowned self] () -> Void in
            self.LeftStack?.removeFromParent()
            
            let maxGap = Int(self.PlayAbleRect.width - (self.RightStack?.frame.size.width)! - self.StackMaxWidth)
            let gap = CGFloat(RandomInRange(Int(self.StackGapMinWitth)...maxGap))
            
            self.LeftStack = self.RightStack
            self.RightStack = self.LoadStacks(true, startLeftPoint: self.PlayAbleRect.origin.x + (self.RightStack?.frame.size.width)! + gap)
        })
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}


private extension StickGokuGameScene {
    func LoadBackGround() {
        guard let _ = childNode(withName: "backfround") as! SKSpriteNode? else{
            let texture = SKTexture(image: UIImage(named: "stick_background.jpg")!)
            let node = SKSpriteNode(texture: texture)
            node.size = texture.size()
            node.zPosition = StickGokuGameSceneZPosition.BackgroundZPosition.rawValue
            self.physicsWorld.gravity = CGVector(dx: 0, dy: Gravity)
            
            addChild(node)
            return
        }
    }
    
    func LoadScore(){
        let scoreBand = SKLabelNode(fontNamed: "Arial")
        scoreBand.name = StickGokuGameSceneChildName.ScoreName.rawValue
        scoreBand.text = "0"
        scoreBand.position = CGPoint(x: 0, y: DefinedScreenWidth / 2 - 200)
        scoreBand.fontColor = SKColor.white
        scoreBand.fontSize = 100
        scoreBand.zPosition = StickGokuGameSceneZPosition.ScoreZPosition.rawValue
        scoreBand.horizontalAlignmentMode = .center
        
        addChild(scoreBand)
    }
    
    func LoadScoreBackGround(){
        let back = SKShapeNode(rect: CGRect(x: 0-120, y: 1024-200-30, width: 240, height: 140), cornerRadius: 20)
        back.zPosition = StickGokuGameSceneZPosition.ScroeBackgroundZPosition.rawValue
        back.fillColor =  SKColor.black.withAlphaComponent(0.3)
        back.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(back)
    }
    
    func LoadGoku(){
        let goku = SKSpriteNode(imageNamed: "Goku1")
        goku.name = StickGokuGameSceneChildName.GokuName.rawValue
        let x: CGFloat = NextLeftStartX - DefinedScreenWidth / 2 - goku.size.width / 2 - GAP.XGAP
        
        // Cambiar nombre a StickHeigth
        let y: CGFloat = StickHeigt  + goku.size.height / 2 - DefinedScreenHeight / 2 - GAP.YGAP
        
        goku.position = CGPoint(x: x, y: y)
        goku.zPosition = StickGokuGameSceneZPosition.GokuZPosition.rawValue
        goku.physicsBody?.affectedByGravity = false
        goku.physicsBody?.allowsRotation = false
        
        addChild(goku)
    }
    
    
    func LoadTip(){
        let tip = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        tip.name = StickGokuGameSceneChildName.TipName.rawValue
        tip.text = "MANTEN PRESIONADO LA PANTLLA"
        tip.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 350)
        tip.fontColor = SKColor.black
        tip.fontSize = 52
        tip.zPosition = StickGokuGameSceneZPosition.TipZPosition.rawValue
        tip.horizontalAlignmentMode = .center
        
        addChild(tip)
    }
    
    
    func LoadPerfect(){
        defer{
            let perfect = childNode(withName: StickGokuGameSceneChildName.PerfectName.rawValue) as! SKLabelNode?
            let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
            let scale = SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
            perfect!.run(SKAction.group([sequence, scale]))
        }
        
        guard let _ = childNode(withName: StickGokuGameSceneChildName.PerfectName.rawValue) as! SKLabelNode? else{
            
            let perfect = SKLabelNode(fontNamed: "Arial")
            perfect.text = "Perfecto +1"
            perfect.name = StickGokuGameSceneChildName.PerfectName.rawValue
            perfect.position = CGPoint(x: 0, y: -100)
            perfect.fontColor = SKColor.black
            perfect.fontSize = 50
            perfect.zPosition = StickGokuGameSceneZPosition.PerfectZPostion.rawValue
            perfect.horizontalAlignmentMode = .center
            perfect.alpha = 0
            
            addChild(perfect)
            
            return
        }
        
    }
    
    
    func LoadStick() -> SKSpriteNode{
        let goku = childNode(withName: StickGokuGameSceneChildName.GokuName.rawValue) as! SKSpriteNode
        
        let stick = SKSpriteNode(color: SKColor.black, size: CGSize(width: 12, height: 1))
        stick.zPosition = StickGokuGameSceneZPosition.StickZPostion.rawValue
        stick.name = StickGokuGameSceneChildName.StickName.rawValue
        stick.anchorPoint = CGPoint(x: 0.5, y: 0);
        stick.position = CGPoint(x: goku.position.x + goku.size.width / 2 + 18, y: goku.position.y - goku.size.height / 2)
        addChild(stick)
        
        return stick
    }
    
    
    func LoadStacks(_ animate: Bool, startLeftPoint: CGFloat) -> SKShapeNode{
        let max: Int = Int(StackMaxWidth / 10)
        let min: Int = Int(StackMinWidth / 10)
        let width: CGFloat = CGFloat(RandomInRange(min...max) * 10)
        let height: CGFloat = StackHeight
        let stack = SKShapeNode(rectOf: CGSize(width: width, height: height))
        stack.fillColor = SKColor.red
        stack.strokeColor = SKColor.black
        stack.zPosition = StickGokuGameSceneZPosition.StackZPosition.rawValue
        stack.name = StickGokuGameSceneChildName.StackName.rawValue
        
        if animate{
            stack.position = CGPoint(x: DefinedScreenWidth / 2, y: -DefinedScreenHeight / 2 + height / 2)
            
            stack.run(SKAction.moveTo(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, duration: 0.3), completion: {[unowned self] () -> Void in
                self.IsBegin = false
                self.IsEnd = false
            })
        }else{
            stack.position = CGPoint(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, y: -DefinedScreenHeight / 2 + height / 2)
        }
        addChild(stack)
        
        let mid = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        mid.fillColor = SKColor.red
        mid.strokeColor = SKColor.red
        mid.zPosition = StickGokuGameSceneZPosition.StackMidZPosition.rawValue
        mid.position = CGPoint(x: 0, y: height / 2 - 20 / 2)
        stack.addChild(mid)
        
        NextLeftStartX = width + startLeftPoint
        
        return stack
        
    }
    
    
    func LoadGameOverLayer(){
        let node = SKNode()
        node.alpha = 0
        node.name = StickGokuGameSceneChildName.GameOverLayerName.rawValue
        node.zPosition = StickGokuGameSceneZPosition.GameOverZPosition.rawValue
        addChild(node)
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "Game Over"
        label.fontColor = SKColor.red
        label.fontSize = 150
        label.position = CGPoint(x: 0, y: 100)
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        
        let retry = SKSpriteNode(imageNamed: "button_retry_up")
        retry.name = StickGokuGameSceneChildName.RetryButtonName.rawValue
        retry.position = CGPoint(x: 0, y: -200)
        node.addChild(retry)
        
        let highScore = SKLabelNode(fontNamed: "AmericanTypewriter")
        highScore.text = "HighScore!"
        highScore.fontColor = UIColor.white
        highScore.fontSize = 50
        highScore.position = CGPoint(x: 0, y: 300)
        highScore.horizontalAlignmentMode = .center
        highScore.setScale(0)
        node.addChild(highScore)
    }
    
    func StarEmitterActionAtPosition(_ position: CGPoint) -> SKAction{
        let emitter = SKEmitterNode(fileNamed: "StarExploosion")
        emitter?.position = position
        emitter?.zPosition = StickGokuGameSceneZPosition.EmitterZPosition.rawValue
        emitter?.alpha = 0.6
        addChild(emitter!)
        
        let wait = SKAction.wait(forDuration: 0.15)
        
        return SKAction.run({() -> Void in
            emitter?.run(wait)
        })
    }
}
