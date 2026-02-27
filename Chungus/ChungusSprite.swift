//
//  ChungusSprite.swift
//  Chungus
//
//  Created by Anto Z on 2/23/26.
//

import SpriteKit
import Combine 

class SpriteStats: ObservableObject {
    @Published var rest: Double = 10
    @Published var abs: Double = 0
    @Published var weight: Double = 20
    @Published var intellect: Double = 10
}

class ChungusScene: SKScene {
    
    var mouseOffset: CGPoint?
    var currentSprite: SKSpriteNode!
    var idleSprite: SKSpriteNode!
    var walkingSprite: [SKSpriteNode]!
    var jumpRopeSprite: [SKSpriteNode]!
    var eatingSprite: [SKSpriteNode]!
    var walkingAnimationIndex: Int = 0
    
    var dizzySprite: SKSpriteNode!
    var sleepingSprite: SKSpriteNode!
    var studyingSprite: SKSpriteNode!
    var isMovingLeft: Bool = false
    var isDragged: Bool = false
    var preDragSprite: SKSpriteNode?
    var fatScale: Float = 1.0
    
    var stats: SpriteStats!
    var currentTask: String = "auto"
    
    var prevX: Double = 0
    var prevY: Double = 0
    var x: Double = 0
    var y: Double = 0
    
    init(size: CGSize, stats: SpriteStats) {
        self.stats = stats
        super.init(size: size)
        self._initSprite()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadSprite(name: String, width: Double, height: Double) -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: name)
        sprite.size = CGSize(width: width, height: height)
        sprite.name = name
        return sprite
    }
    
    func _initSprite() {
        self.backgroundColor = .clear
        
        self.x = ScreenConstant.width / 2
        self.y = ScreenConstant.height / 2
        
        self.idleSprite = loadSprite(
            name: "ChungusIdle",
            width: SpriteConstant.width,
            height: SpriteConstant.height)

        
        self.dizzySprite = loadSprite(
            name: "ChungusDizzy",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        self.sleepingSprite = loadSprite(
            name: "ChungusSleeping",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        self.studyingSprite = loadSprite(
            name: "ChungusStudying",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        let walkingSprite1 = loadSprite(
            name: "ChungusWalk1",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        let walkingSprite2 = loadSprite(
            name: "ChungusWalk2",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        let jumpRopeSprite1 = loadSprite(
            name: "ChungusJumpRope1",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        let jumpRopeSprite2 = loadSprite(
            name: "ChungusJumpRope2",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        let jumpRopeSprite3 = loadSprite(
            name: "ChungusJumpRope3",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        let eatingSprite1 = loadSprite(
            name: "ChungusEating1",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        let eatingSprite2 = loadSprite(
            name: "ChungusEating2",
            width: SpriteConstant.width,
            height: SpriteConstant.height)
        
        self.jumpRopeSprite = [jumpRopeSprite1, jumpRopeSprite2, jumpRopeSprite3]
        self.walkingSprite = [walkingSprite1, walkingSprite2]
        self.eatingSprite = [eatingSprite1, eatingSprite2]
        
        self.currentSprite = idleSprite
        
        addChild(currentSprite)
        
        self.restartSpriteLoop()
        
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let clickedNode = atPoint(location)
        
        if clickedNode.name != nil && clickedNode.name!.contains("Chungus") {
            mouseOffset = event.locationInWindow
            
            if event.clickCount == 2{
                MenuManager.shared.openMenu(for: self.currentSprite, selectTaskHandler: self.handleSpriteTask, stats: self.stats)
                return
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        guard self.view?.window != nil, let offset = mouseOffset else { return }
        
        if !self.isDragged {
            self.preDragSprite = self.currentSprite
            self.isDragged = true
        }
        
        let mouseInScreen = NSEvent.mouseLocation
        
        self.x = mouseInScreen.x - offset.x
        self.y = mouseInScreen.y - offset.y
        // This is so we set it back to idle
        self.prevX = self.x
        self.prevY = self.y
        
        self.renderSprite()
    }
    
    override func mouseUp(with event: NSEvent) {
        mouseOffset = nil
        self.isDragged = false
        
        if let previousSprite = self.preDragSprite {
            self.renderSprite(replaceSprite: previousSprite)
            self.preDragSprite = nil
        } else {
            self.renderSprite()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 49: // Space bar
            if RuneTimeConstant.spriteDebug {
                print("Space Pressed")
            }
        default:
            
            if RuneTimeConstant.spriteDebug {
                print("Key code: \(event.keyCode)")
            }
        }
    }
    
    func renderSprite(replaceSprite: SKSpriteNode? = nil, yOffset: CGFloat = 0) {
        guard let window = self.view?.window else { return }
        
        self.currentSprite.removeFromParent()
        
        var directionScale: CGFloat = 1
        
        if let newSprite = replaceSprite {
            self.currentSprite = newSprite
        } else {
            let dx = self.x - self.prevX
            if dx == 0 {
                self.currentSprite = self.idleSprite
            } else {
                self.currentSprite = self.walkingSprite[self.walkingAnimationIndex]
                self.walkingAnimationIndex = Int(CACurrentMediaTime() * 10) % self.walkingSprite.count
                directionScale = dx < 0 ? -1 : 1
            }
        }
        
        if self.isDragged {
            self.dizzySprite.xScale = Int(CACurrentMediaTime() * 10) % 2 == 0 ? 1 : -1
            self.currentSprite = self.dizzySprite
        }
        
        self.fatScale = Float(self.stats.weight / SpriteConstant.baseWeight)
        self.currentSprite.xScale = CGFloat(self.fatScale)
        self.currentSprite.yScale = CGFloat(self.fatScale)
        
        self.currentSprite.position = CGPoint(x: size.width / 2, y: (size.height / 2) + yOffset)
        self.currentSprite.xScale *= directionScale
        addChild(self.currentSprite)
        
        // THE FIX: Use self.y + yOffset for the visual position,
        // but self.y stays pure (where the mouse is).
        window.setFrameOrigin(CGPoint(x: self.x, y: self.y + yOffset))
    }
    
    func walk(dx: Double, dy: Double) {
        
        if self.isDragged { return }
        
        self.prevX = self.x
        self.prevY = self.y
        
        self.x = dx + self.x > ScreenConstant.width ? self.x : dx + self.x
        self.y = dy + self.y > ScreenConstant.height ? self.y : dy + self.y
        
        self.renderSprite()
    }
    
    func isOutOfBound(x: Double, y: Double) -> Bool {
        return x < 0 || x + SpriteConstant.width > ScreenConstant.width || y < 0 || y + SpriteConstant.height > ScreenConstant.height
    }
    
    func getWalkingAction(config: [String: Any]) -> SKAction {
        
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        let step = config["step"] as? Int ?? 2
        
        let walkDuration = Double.random(in: lowerDuration...upperDuration)
        let frameDuration = 0.02
        let iterations = Int(walkDuration / frameDuration)
        
        let direction = [-1.0, 1.0].randomElement() ?? 1.0
        let step_size = direction * Double(step)
        
        var stepActions: [SKAction] = []
        
        for _ in 0..<iterations {
            let moveStep = SKAction.run {
                if !self.isOutOfBound(x: self.x + step_size, y: self.y) {
                    self.walk(dx: step_size, dy: 0)
                }
            }
            let waitStep = SKAction.wait(forDuration: frameDuration)
            stepActions.append(moveStep)
            stepActions.append(waitStep)
        }
        
        let resetToIdle = SKAction.run {
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([SKAction.sequence(stepActions), resetToIdle])
    }
    
    func getSleepingAction(config: [String: Any]) -> SKAction {
            
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        
        let sleepDuration = Double.random(in: lowerDuration...upperDuration)
        let frameDuration = 0.75
        let totalBreaths = max(1, Int(sleepDuration / (frameDuration * 2)))
        let actualSleepTime = Double(totalBreaths) * (frameDuration * 2)
        
        let setSprite = SKAction.run {
            self.renderSprite(replaceSprite: self.sleepingSprite)
            
            let breatheOut = SKAction.scaleY(to: 0.9, duration: frameDuration)
            let breatheIn = SKAction.scaleY(to: 1.0, duration: frameDuration)
            
            let oneFullBreath = SKAction.sequence([breatheOut, breatheIn])
            let breathingLoop = SKAction.repeat(oneFullBreath, count: totalBreaths)
            
            self.currentSprite.run(breathingLoop, withKey: "Breathing")
        }
        
        let wait = SKAction.wait(forDuration: actualSleepTime)
        
        let resetToIdle = SKAction.run {
            self.currentSprite.yScale = 1.0
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([setSprite, wait, resetToIdle])
    }
        
    func getStudyingAction(config: [String: Any]) -> SKAction {
        
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        
        let setSprite = SKAction.run {
            self.renderSprite(replaceSprite: self.studyingSprite)
        }
        
        let studyDuration = Double.random(in: lowerDuration...upperDuration)
        let wait = SKAction.wait(forDuration: studyDuration)
        
        let resetToIdle = SKAction.run {
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([setSprite, wait, resetToIdle])
    }
    
    func getJumpRopeAction(config: [String: Any]) -> SKAction {
        
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        let duration = Double.random(in: lowerDuration...upperDuration)
        let jumpHeight: Double = 30.0
        
        // customAction gives us 'elapsedTime', which is perfect for syncing
        let jumpRopeAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            // 1. Calculate the repeating progress (0.0 to 1.0)
            let speed = 2.0
            let progress = (Double(elapsedTime) * speed).truncatingRemainder(dividingBy: 1.0)
            
            // 2. Calculate visual jump offset
            let bounce = sin(progress * .pi) * jumpHeight
            
            // 3. Texture Sync
            let frameIndex: Int
            if progress < 0.33 { frameIndex = 0 }
            else if progress < 0.66 { frameIndex = 1 }
            else { frameIndex = 2 }
            
            let safeIndex = min(frameIndex, self.jumpRopeSprite.count - 1)
            
            // 4. RENDER with the offset!
            // We pass the bounce as an 'offset' so we don't change self.y
            self.renderSprite(replaceSprite: self.jumpRopeSprite[safeIndex], yOffset: bounce)
        }
        
        let resetToIdle = SKAction.run {
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([jumpRopeAction, resetToIdle])
        
    }
    
    func getEatingAction(config: [String: Any]) -> SKAction {
        
        let lowerDuration = config["lowerDuration"] as? Double ?? 2.0
        let upperDuration = config["upperDuration"] as? Double ?? 5.0
        
        let eatingDuration = Double.random(in: lowerDuration...upperDuration)
        let frameDuration = 0.25
        let iterations = Int(eatingDuration / frameDuration)
        
        var stepActions: [SKAction] = []
        
        for i in 0..<iterations {
            let changeFrame = SKAction.run { self.renderSprite(replaceSprite: self.eatingSprite[i % 2])  }
            let waitStep = SKAction.wait(forDuration: frameDuration)
            stepActions.append(changeFrame)
            stepActions.append(waitStep)
        }
        
        let resetToIdle = SKAction.run {
            self.prevX = self.x
            self.renderSprite()
        }
        
        return SKAction.sequence([SKAction.sequence(stepActions), resetToIdle])
    }
    
    func taskToFunction(taskName: String) -> ([String: Any]) -> (SKAction) {
        switch taskName.lowercased() {
            case "study":
            return self.getStudyingAction
        case "sleep":
            return self.getSleepingAction
        case "walk":
            return self.getWalkingAction
        case "exercise":
            return self.getJumpRopeAction
        case "eat":
            return self.getEatingAction
        default:
            return { _ in SKAction.wait(forDuration: 0.0)}
        }
    }
    
    func applyActionToStats(taskName: String) -> SKAction {
        
        let statsAction = SKAction.run {
            switch taskName.lowercased() {
            case "study":
                self.stats.intellect += 1.0
            case "sleep":
                self.stats.rest += 1.0
            case "walk":
                self.stats.abs += 0.2
            case "exercise":
                self.stats.abs += 1.0
                self.stats.weight -= 1.0
            case "eat":
                self.stats.weight += 1
            default:
                break
            }
        }
        
        return statsAction
    }
    
    func restartSpriteLoop(){
        self.removeAction(forKey: "SpriteLoop")
        self.spriteLoop(lowerDuration: 3, upperDuration: 10, lowerDelay: 2, upperDelay: 5)
    }

    func spriteLoop(lowerDuration: Double, upperDuration: Double, lowerDelay: Double = 2.0, upperDelay: Double = 5.0, step: Int = 2) {
                
        let config: [String: Any] = [
            "lowerDuration": lowerDuration,
            "upperDuration": upperDuration,
            "step": step
        ]
        
        var chosenAction: String
        var waitBetween: SKAction
                
        if self.currentTask == "auto" {
            let availabelActions = ["sleep", "exercise", "study", "walk", "eat"]
            chosenAction = availabelActions.randomElement() ?? "study"
            waitBetween = SKAction.wait(forDuration: Double.random(in: lowerDelay...upperDelay))
        } else{
            chosenAction = self.currentTask
            waitBetween = SKAction.wait(forDuration: 0.0)
        }
        print("Chosen Action: \(chosenAction)")
        let chosenFunction = self.taskToFunction(taskName: chosenAction)
        let statsAction = self.applyActionToStats(taskName: chosenAction)
        let actionSequence = chosenFunction(config)
        
        let queueNext = SKAction.run { [weak self] in
            self?.spriteLoop(
                lowerDuration: lowerDuration,
                upperDuration: upperDuration,
                lowerDelay: lowerDelay,
                upperDelay: upperDelay,
                step: step
            )
        }
        
        let mainSequence = SKAction.sequence([actionSequence, statsAction, waitBetween, queueNext])
        
        self.run(mainSequence, withKey: "SpriteLoop")
    }
    
    func handleSpriteTask(taskName: String) {
        self.currentTask = taskName.lowercased()
        print("Task \(self.currentTask) received! < ABSOLUTE")
        self.restartSpriteLoop()
    }
}
