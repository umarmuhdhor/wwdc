import SpriteKit
import GameplayKit

class HuntingGameScene: SKScene, SKPhysicsContactDelegate {
    private var audioManager = AudioPlayerManager()
    
    // MARK: - Properties
    private var sangkuriang: SKSpriteNode!
    private var bow: SKSpriteNode!
    private var tumang: SKSpriteNode!
    private var arrow: SKSpriteNode!
    private var bowString: SKShapeNode?
    private var trajectoryPoints: [SKShapeNode] = []
    
    // Game State Properties
    private var isAiming = false
    private var startPosition: CGPoint?
    private var bowStringRestPosition: CGPoint?
    private var springRestPosition: CGPoint!
    private var initialTouchPosition: CGPoint!
    private var shootingPower: CGFloat = 0
    private var gameState: GameState = .aiming
    private var dialogBox: SKNode?
    private var winSound: SKAction!
    
    // Configuration Constants
    private let maxShootingDistance: CGFloat = 1000
    private let springConstant: CGFloat = 0.8
    private let maxPullbackDistance: CGFloat = 100.0
    
    // MARK: - Game States
    enum GameState {
        case aiming
        case shooting
        case choosing
        case completed
        case missed
    }
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBackground()
        setupCharacters()
        setupBow()
        setupInstructions()
        setupBoundaries()
    }
    
    private func setupPhysicsWorld() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "forest_background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupCharacters() {
        // Sangkuriang setup
        sangkuriang = SKSpriteNode(imageNamed: "Sangkuriang_Child")
        sangkuriang.position = CGPoint(x: frame.midX - 300, y: 120)
        sangkuriang.setScale(0.5)
        sangkuriang.zPosition = 1
        addChild(sangkuriang)
        
        // Tumang setup - Modified to be at the bottom
        tumang = SKSpriteNode(imageNamed: "Tumang_Dog")
        tumang.position = CGPoint(x: frame.midX + 400, y: 70) // Fixed position at bottom
        tumang.setScale(0.3)
        tumang.zPosition = 1
        
        let smallerSize = CGSize(width: tumang.size.width * 0.6, height: tumang.size.height * 0.6)
        tumang.physicsBody = SKPhysicsBody(rectangleOf: smallerSize)
        tumang.physicsBody?.isDynamic = false
        tumang.physicsBody?.affectedByGravity = false
        tumang.physicsBody?.categoryBitMask = PhysicsCategory.tumang
        tumang.physicsBody?.contactTestBitMask = PhysicsCategory.arrow
        tumang.physicsBody?.collisionBitMask = PhysicsCategory.boundary
        
        addChild(tumang)
    }
    
    private func setupBow() {
        bow = SKSpriteNode(imageNamed: "bow")
        bow.position = CGPoint(x: sangkuriang.position.x + 30, y: sangkuriang.position.y + 20)
        bow.setScale(0.3)
        bow.zPosition = 2
        addChild(bow)
        
        bowString = SKShapeNode()
        bowString?.strokeColor = .white
        bowString?.lineWidth = 2
        bowString?.zPosition = 2
        if let bowString = bowString {
            addChild(bowString)
        }
        
        bowStringRestPosition = CGPoint(x: bow.position.x, y: bow.position.y)
        springRestPosition = bow.position
        
        let stringPath = CGMutablePath()
        stringPath.move(to: bowStringRestPosition!)
        stringPath.addLine(to: bowStringRestPosition!)
        bowString?.path = stringPath
    }
    
    private func setupInstructions() {
        let instructions = SKLabelNode(text: "Pull back to aim, release to shoot")
        instructions.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        instructions.fontName = "HelveticaNeue-Bold"
        instructions.fontSize = 24
        instructions.fontColor = .white
        addChild(instructions)
    }
    
    private func setupBoundaries() {
        let boundary = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = boundary
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.categoryBitMask = PhysicsCategory.boundary
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState == .aiming, let touch = touches.first else { return }
        initialTouchPosition = touch.location(in: self)
        
        arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.position = bow.position
        arrow.setScale(0.1)
        arrow.zPosition = 2
        
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.isDynamic = false
        arrow.physicsBody?.affectedByGravity = false
        arrow.physicsBody?.categoryBitMask = PhysicsCategory.arrow
        arrow.physicsBody?.contactTestBitMask = PhysicsCategory.tumang | PhysicsCategory.boundary
        arrow.physicsBody?.collisionBitMask = 0
        arrow.physicsBody?.mass = 0.1
        arrow.physicsBody?.linearDamping = 0.5
        
        addChild(arrow)
        isAiming = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAiming, let touch = touches.first else { return }
        let currentPosition = touch.location(in: self)
        
        let dx = currentPosition.x - initialTouchPosition.x
        let dy = currentPosition.y - initialTouchPosition.y
        let pullDistance = sqrt(dx * dx + dy * dy)
        
        let clampedDistance = min(pullDistance, maxPullbackDistance)
        let angle = atan2(dy, dx)
        
        let springForceX = -cos(angle) * clampedDistance * springConstant
        let springForceY = -sin(angle) * clampedDistance * springConstant
        
        let arrowX = springRestPosition.x + springForceX
        let arrowY = springRestPosition.y + springForceY
        arrow.position = CGPoint(x: arrowX, y: arrowY)
        arrow.zRotation = angle + .pi
        
        let stringPath = CGMutablePath()
        stringPath.move(to: bowStringRestPosition!)
        stringPath.addLine(to: CGPoint(x: arrowX, y: arrowY))
        bowString?.path = stringPath
        
        shootingPower = clampedDistance / maxPullbackDistance
        updateTrajectoryPrediction(from: arrow.position, angle: angle + .pi, power: shootingPower)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAiming else { return }
        gameState = .shooting
        
        trajectoryPoints.forEach { $0.removeFromParent() }
        trajectoryPoints.removeAll()
        
        let stringPath = CGMutablePath()
        stringPath.move(to: bowStringRestPosition!)
        stringPath.addLine(to: bowStringRestPosition!)
        bowString?.path = stringPath
        
        arrow.physicsBody?.isDynamic = true
        arrow.physicsBody?.affectedByGravity = true
        
        let angle = arrow.zRotation
        let springVelocity = shootingPower * 3000 // Meningkatkan kecepatan tembakan
        let velocityX = cos(angle) * springVelocity * 1.5 // Meningkatkan kecepatan horizontal
        let velocityY = sin(angle) * springVelocity * 1.5 // Meningkatkan kecepatan vertikal
        
        let limitedVelocityX = min(abs(velocityX), maxShootingDistance) * sign(velocityX)
        let limitedVelocityY = min(abs(velocityY), maxShootingDistance) * sign(velocityY)
        
        arrow.physicsBody?.velocity = CGVector(dx: limitedVelocityX, dy: limitedVelocityY)
        
        let trackingAction = SKAction.customAction(withDuration: 5.0) { [weak self] node, _ in
            guard let arrow = node as? SKSpriteNode,
                  let velocity = arrow.physicsBody?.velocity else { return }
            
            let currentSpeed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
            if currentSpeed > self?.maxShootingDistance ?? 600 {
                let scale = (self?.maxShootingDistance ?? 600) / currentSpeed
                arrow.physicsBody?.velocity = CGVector(
                    dx: velocity.dx * scale,
                    dy: velocity.dy * scale
                )
            }
            
            let angle = atan2(velocity.dy, velocity.dx)
            arrow.zRotation = angle
        }
        arrow.run(trackingAction)
        
        isAiming = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.checkMiss()
        }
    }
    
    // MARK: - Trajectory Prediction
    private func updateTrajectoryPrediction(from startPoint: CGPoint, angle: CGFloat, power: CGFloat) {
        trajectoryPoints.forEach { $0.removeFromParent() }
        trajectoryPoints.removeAll()
        
        let springVelocity = power * 800
        let velocity = CGVector(
            dx: cos(angle) * springVelocity,
            dy: sin(angle) * springVelocity
        )
        
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        let limitedVelocity: CGVector
        if speed > maxShootingDistance {
            let scale = maxShootingDistance / speed
            limitedVelocity = CGVector(
                dx: velocity.dx * scale,
                dy: velocity.dy * scale
            )
        } else {
            limitedVelocity = velocity
        }
        
        let gravity = CGVector(dx: 0, dy: -9.8)
        let timeStep: CGFloat = 0.1
        let numPoints = 20
        
        var position = startPoint
        var currentVelocity = limitedVelocity
        
        for i in 0..<numPoints {
            let point = SKShapeNode(circleOfRadius: 2)
            point.fillColor = .white
            point.strokeColor = .white
            point.alpha = 1.0 - (CGFloat(i) / CGFloat(numPoints))
            point.position = position
            point.zPosition = 1
            addChild(point)
            trajectoryPoints.append(point)
            
            position.x += currentVelocity.dx * timeStep
            position.y += currentVelocity.dy * timeStep
            currentVelocity.dy += gravity.dy * timeStep
        }
    }
    
    // MARK: - Collision Handling
    func didBegin(_ contact: SKPhysicsContact) {
        guard gameState == .shooting else { return }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.arrow &&
            contact.bodyB.categoryBitMask == PhysicsCategory.tumang) ||
            (contact.bodyA.categoryBitMask == PhysicsCategory.tumang &&
             contact.bodyB.categoryBitMask == PhysicsCategory.arrow) {
            
            arrow.physicsBody?.isDynamic = false
            arrow.physicsBody?.affectedByGravity = false
            arrow.removeAllActions()
            
            tumang.physicsBody?.isDynamic = true
            tumang.physicsBody?.affectedByGravity = true
            
            gameState = .choosing
            showGameComplete()
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.arrow ||
                    contact.bodyB.categoryBitMask == PhysicsCategory.arrow {
            arrow.physicsBody?.isDynamic = false
            arrow.physicsBody?.affectedByGravity = false
            arrow.removeAllActions()
        }
    }
    
    // MARK: - Game State Management
    private func checkMiss() {
        guard gameState == .shooting else { return }
        gameState = .missed
        showMissMessage()
    }
    
    private func showMissMessage() {
        let missLabel = SKLabelNode(text: "Missed! Try again")
        missLabel.fontName = "HelveticaNeue-Bold"
        missLabel.fontSize = 32
        missLabel.fontColor = .red
        missLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        missLabel.zPosition = 10
        addChild(missLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            missLabel.removeFromParent()
            self?.resetScene()
        }
    }
    
    private func createButton(text: String, position: CGPoint, action: @escaping () -> Void) -> SKNode {
        let button = SKSpriteNode(color: .blue, size: CGSize(width: 300, height: 50))
        button.position = position
        button.alpha = 0.8
        
        let label = SKLabelNode(text: text)
        label.fontName = "HelveticaNeue"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        
        button.addChild(label)
        
        let touchNode = SKNode()
        touchNode.name = text
        touchNode.userData = ["action": action]
        button.addChild(touchNode)
        
        return button
    }
    
    private func showGameComplete() {
        // Play audio
        audioManager.playAudio(filename: "right")

        // Create a semi-transparent black background
        let background = SKSpriteNode(color: .black, size: CGSize(width: frame.width, height: frame.height))
        background.alpha = 0.7
        background.zPosition = 11
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)

        // Create the "Game Complete" label
        let gameCompleteLabel = SKLabelNode(text: "🎉  You Win !!!  🎉")
        gameCompleteLabel.fontName = "HelveticaNeue-Bold"
        gameCompleteLabel.fontSize = 24
        gameCompleteLabel.fontColor = .white
        gameCompleteLabel.zPosition = 12
        gameCompleteLabel.horizontalAlignmentMode = .center
        gameCompleteLabel.verticalAlignmentMode = .center

        // Calculate the size of the label background
        let padding: CGFloat = 30
        let labelWidth = gameCompleteLabel.frame.width + padding
        let labelHeight = gameCompleteLabel.frame.height + padding

        // Create a rounded rectangle background for the label
        let labelBackground = SKShapeNode(rect: CGRect(x: -labelWidth / 2, y: -labelHeight / 2, width: labelWidth, height: labelHeight), cornerRadius: 15)
        labelBackground.fillColor = .green
        labelBackground.strokeColor = .white
        labelBackground.lineWidth = 2
        labelBackground.alpha = 0.8
        labelBackground.zPosition = 11
        labelBackground.position = CGPoint(x: frame.midX, y: frame.midY)

        // Add the label to the background
        labelBackground.addChild(gameCompleteLabel)

        // Add the label background to the scene
        addChild(labelBackground)

        // Send notification that the game is completed
        NotificationCenter.default.post(name: Notification.Name("GameCompleted"), object: nil)
    }
    
    private func resetScene() {
        // Remove game elements
        arrow?.removeFromParent()
        dialogBox?.removeFromParent()
        trajectoryPoints.forEach { $0.removeFromParent() }
        trajectoryPoints.removeAll()
        
        // Reset bow string
        let stringPath = CGMutablePath()
        stringPath.move(to: bowStringRestPosition!)
        stringPath.addLine(to: bowStringRestPosition!)
        bowString?.path = stringPath
        
        // Reset Tumang
        tumang.physicsBody?.isDynamic = false
        tumang.physicsBody?.affectedByGravity = false
        tumang.position = CGPoint(x: frame.midX + 400, y: tumang.size.height / 2)
        tumang.zRotation = 0
        
        // Reset game state
        gameState = .aiming
        isAiming = false
        shootingPower = 0
    }
}


// MARK: - Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let arrow: UInt32 = 0b1
    static let tumang: UInt32 = 0b10
    static let boundary: UInt32 = 0b100
}
