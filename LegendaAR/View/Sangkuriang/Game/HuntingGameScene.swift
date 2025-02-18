import SpriteKit
import GameplayKit

class HuntingGameScene: SKScene, SKPhysicsContactDelegate {
    private var sangkuriang: SKSpriteNode!
    private var tumang: SKSpriteNode!
    private var arrow: SKSpriteNode!
    private var isAiming = false
    private var aimingLine: SKShapeNode?
    private var startPosition: CGPoint?
    private var gameState: GameState = .aiming
    private var dialogBox: SKNode?
    private var shootingPower: CGFloat = 0
    
    enum GameState {
        case aiming
        case shooting
        case choosing
        case completed
        case missed
    }
    
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBackground()
        setupCharacters()
        setupInstructions()
        setupBoundaries()
    }
    
    private func setupPhysicsWorld() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }
    
    private func setupBoundaries() {
        let boundary = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = boundary
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 0.5
        self.physicsBody?.categoryBitMask = PhysicsCategory.boundary
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "forest_background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupCharacters() {
        // Setup Sangkuriang
        sangkuriang = SKSpriteNode(imageNamed: "Sangkuriang")
        sangkuriang.position = CGPoint(x: frame.midX - 200, y: frame.midY)
        sangkuriang.setScale(0.5)
        sangkuriang.zPosition = 1
        addChild(sangkuriang)
        
        // Setup Tumang with a smaller hit area
        tumang = SKSpriteNode(imageNamed: "Tumang_dog")
        tumang.position = CGPoint(x: frame.midX + 200, y: frame.midY)
        tumang.setScale(0.3)
        tumang.zPosition = 1
        tumang.name = "tumang"
        
        // Create a smaller physics body for more precise hit detection
        let smallerSize = CGSize(width: tumang.size.width * 0.6, height: tumang.size.height * 0.6)
        tumang.physicsBody = SKPhysicsBody(rectangleOf: smallerSize)
        tumang.physicsBody?.isDynamic = false  // Make static until hit
        tumang.physicsBody?.affectedByGravity = false  // Prevent gravity effect
        tumang.physicsBody?.categoryBitMask = PhysicsCategory.tumang
        tumang.physicsBody?.contactTestBitMask = PhysicsCategory.arrow
        tumang.physicsBody?.collisionBitMask = 0
        
        addChild(tumang)
    }
    
    private func setupInstructions() {
        let instructions = SKLabelNode(text: "Tap and drag to aim, release to shoot")
        instructions.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        instructions.fontName = "HelveticaNeue-Bold"
        instructions.fontSize = 24
        instructions.fontColor = .white
        instructions.name = "instructions"
        addChild(instructions)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState == .aiming, let touch = touches.first else { return }
        startPosition = touch.location(in: self)
        
        // Create aiming line
        aimingLine = SKShapeNode()
        aimingLine?.strokeColor = .white
        aimingLine?.lineWidth = 2
        aimingLine?.zPosition = 3
        addChild(aimingLine!)
        
        // Create arrow with physics disabled initially
        arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.position = sangkuriang.position
        arrow.setScale(0.3)
        arrow.zPosition = 2
        
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.isDynamic = false  // Disable physics initially
        arrow.physicsBody?.affectedByGravity = false  // Disable gravity initially
        arrow.physicsBody?.categoryBitMask = PhysicsCategory.arrow
        arrow.physicsBody?.contactTestBitMask = PhysicsCategory.tumang | PhysicsCategory.boundary
        arrow.physicsBody?.collisionBitMask = PhysicsCategory.boundary
        arrow.physicsBody?.mass = 0.1
        
        addChild(arrow)
        isAiming = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAiming, let touch = touches.first, let start = startPosition else { return }
        let currentPosition = touch.location(in: self)
        
        // Update aiming line
        let path = CGMutablePath()
        path.move(to: sangkuriang.position)
        path.addLine(to: currentPosition)
        aimingLine?.path = path
        
        // Calculate power based on drag distance
        let dx = currentPosition.x - start.x
        let dy = currentPosition.y - start.y
        shootingPower = sqrt(dx * dx + dy * dy) / 100
        shootingPower = min(shootingPower, 2.0) // Cap the power
        
        // Update arrow position and rotation while aiming
        let angle = atan2(currentPosition.y - start.y, currentPosition.x - start.x)
        arrow.position = sangkuriang.position
        arrow.zRotation = angle
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAiming, let touch = touches.first, let start = startPosition else { return }
        gameState = .shooting
        
        let currentPosition = touch.location(in: self)
        let dx = currentPosition.x - start.x
        let dy = currentPosition.y - start.y
        
        // Enable physics for arrow
        arrow.physicsBody?.isDynamic = true
        arrow.physicsBody?.affectedByGravity = true
        
        // Apply impulse to arrow
        let impulse = CGVector(dx: dx * shootingPower, dy: dy * shootingPower)
        arrow.physicsBody?.applyImpulse(impulse)
        
        // Remove aiming line
        aimingLine?.removeFromParent()
        isAiming = false
        
        // Start miss detection timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.checkMiss()
        }
    }
    
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard gameState == .shooting else { return }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.arrow &&
            contact.bodyB.categoryBitMask == PhysicsCategory.tumang) ||
            (contact.bodyA.categoryBitMask == PhysicsCategory.tumang &&
             contact.bodyB.categoryBitMask == PhysicsCategory.arrow) {
            
            // Enable physics for Tumang when hit
            tumang.physicsBody?.isDynamic = true
            tumang.physicsBody?.affectedByGravity = true
            
            gameState = .choosing
            showChoiceDialog()
        }
    }
    
    private func showChoiceDialog() {
        let dialogBackground = SKSpriteNode(color: .black, size: CGSize(width: 500, height: 300))
        dialogBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        dialogBackground.alpha = 0.8
        dialogBackground.zPosition = 10
        dialogBackground.name = "dialogBox"
        
        let title = SKLabelNode(text: "What will you do?")
        title.position = CGPoint(x: 0, y: 80)
        title.fontName = "HelveticaNeue-Bold"
        title.fontSize = 28
        title.fontColor = .white
        
        let handOverButton = createButton(
            text: "Hand over Tumang's heart",
            position: CGPoint(x: 0, y: 20),
            action: { [weak self] in
                self?.handleChoice(choice: "handOver")
            }
        )
        
        let searchButton = createButton(
            text: "Search for another animal",
            position: CGPoint(x: 0, y: -40),
            action: { [weak self] in
                self?.handleChoice(choice: "search")
            }
        )
        
        dialogBackground.addChild(title)
        dialogBackground.addChild(handOverButton)
        dialogBackground.addChild(searchButton)
        addChild(dialogBackground)
        dialogBox = dialogBackground
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
    
    private func handleChoice(choice: String) {
        switch choice {
        case "handOver":
            gameState = .completed
            NotificationCenter.default.post(
                name: Notification.Name("GameCompleted"),
                object: nil
            )
        case "search":
            resetScene()
        default:
            break
        }
        
        dialogBox?.removeFromParent()
    }
    
    private func resetScene() {
        // Reset all game elements
        arrow?.removeFromParent()
        dialogBox?.removeFromParent()
        aimingLine?.removeFromParent()
        
        // Reset Tumang's physics
        tumang.physicsBody?.isDynamic = false
        tumang.physicsBody?.affectedByGravity = false
        
        gameState = .aiming
    }
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let arrow: UInt32 = 0b1
    static let tumang: UInt32 = 0b10
    static let boundary: UInt32 = 0b100
}
