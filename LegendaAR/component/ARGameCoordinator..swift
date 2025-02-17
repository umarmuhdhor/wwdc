import SwiftUI
import ARKit
import RealityKit

class ARGameCoordinator: NSObject {
    // Bindings and properties
    @Binding var showChoiceDialog: Bool
    @Binding var gameResult: GameResult?
    var audioManager: AudioPlayerManager
    
    // AR View reference
    var arView: ARView?
    var anchor: AnchorEntity?
    
    // Power meter system
    var powerMeterSystem: PowerMeterSystem
    
    init(showChoiceDialog: Binding<Bool>, gameResult: Binding<GameResult?>, audioManager: AudioPlayerManager) {
        self._showChoiceDialog = showChoiceDialog
        self._gameResult = gameResult
        self.audioManager = audioManager
        self.powerMeterSystem = PowerMeterSystem()
        
        super.init()
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let arView = arView, let anchor = anchor else { return }
        
        let tapLocation = gesture.location(in: arView)
        
        // Cast ray to find entities at tap location
        if let hitEntity = findEntityAtTapLocation(tapLocation) {
            // Check if we tapped the dog
            if hitEntity.name == "dog" {
                if !powerMeterSystem.isActive {
                    // Create power meter
                    powerMeterSystem.create(
                        nearEntity: hitEntity,
                        inAnchor: anchor,
                        onShot: { [weak self] power in
                            self?.performShot(at: hitEntity, withPower: power)
                        }
                    )
                }
            }
        }
    }
    
    private func findEntityAtTapLocation(_ location: CGPoint) -> Entity? {
        guard let arView = arView else { return nil }
        
        // Perform hit test
        let results = arView.hitTest(location)
        
        // Find the first entity with a name
        for result in results {
            // Try direct entity
            if !result.entity.name.isEmpty {
                return result.entity
            }
            
            // Check parent entities
            var currentEntity: Entity? = result.entity
            while let entity = currentEntity {
                if !entity.name.isEmpty {
                    return entity
                }
                currentEntity = entity.parent
            }
        }
        
        return nil
    }
    
    func performShot(at target: Entity, withPower power: Float) {
        // Determine if shot was successful based on power level
        let isSuccessful = power >= 0.3 && power <= 0.7
        
        if isSuccessful {
            // Play successful hit sound
            audioManager.playAudio(filename: "ArrowHit")
            
            // Show hit animation
            showHitEffect(at: target)
            
            // After short delay, show dialog
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showChoiceDialog = true
                self.gameResult = .success
            }
        } else {
            // Play miss sound
            audioManager.playAudio(filename: "ArrowMiss")
            
            // Show miss effect
            showMissEffect(near: target)
        }
    }
    
    func showHitEffect(at entity: Entity) {
        // Make the target fall down
        let currentPosition = entity.position
        let fallPosition = SIMD3<Float>(
            currentPosition.x,
            currentPosition.y - 0.2,
            currentPosition.z
        )
        
        // Simple animation
        let fallAction = RotateAction(
            duration: 1.0,
            rotation: simd_quatf(angle: .pi/2, axis: SIMD3<Float>(1, 0, 0))
        )
        
        let moveAction = MoveAction(
            duration: 1.0,
            to: fallPosition
        )
        
        entity.performAction(fallAction)
        entity.performAction(moveAction)
    }
    
    func showMissEffect(near entity: Entity) {
        guard let anchor = anchor else { return }
        
        // Create arrow impact position (slightly off from the target)
        let missOffset = SIMD3<Float>(
            Float.random(in: -0.5...0.5),
            Float.random(in: -0.2...0.2),
            Float.random(in: -0.5...0.5)
        )
        let impactPosition = entity.position + missOffset
        
        // Create a simple visual indication of the miss
        let missIndicator = ModelEntity(
            mesh: .generateSphere(radius: 0.05),
            materials: [SimpleMaterial(color: .gray, isMetallic: false)]
        )
        missIndicator.position = impactPosition
        anchor.addChild(missIndicator)
        
        // Add a simple fade out animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            setOpacity(for: missIndicator, to: 0.8)
            
            // Fade out and remove
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                missIndicator.removeFromParent()
            }
        }
    }
    

}

// Simple action classes to replace BasicAnimation
class RotateAction {
    let duration: TimeInterval
    let rotation: simd_quatf
    
    init(duration: TimeInterval, rotation: simd_quatf) {
        self.duration = duration
        self.rotation = rotation
    }
}

class MoveAction {
    let duration: TimeInterval
    let targetPosition: SIMD3<Float>
    
    init(duration: TimeInterval, to position: SIMD3<Float>) {
        self.duration = duration
        self.targetPosition = position
    }
}

// Add extension to Entity to perform our custom actions
extension Entity {
    func performAction(_ action: RotateAction) {
        let startOrientation = self.orientation
        let startTime = Date()
        
        // Create a timer to animate rotation
        let timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            if elapsedTime >= action.duration {
                self.orientation = action.rotation
                timer.invalidate()
                return
            }
            
            // Linear interpolation for simplicity
            let t = Float(elapsedTime / action.duration)
            self.orientation = simd_slerp(startOrientation, action.rotation, t)
        }
        
        // Keep timer referenced
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func performAction(_ action: MoveAction) {
        let startPosition = self.position
        let startTime = Date()
        
        // Create a timer to animate position
        let timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            if elapsedTime >= action.duration {
                self.position = action.targetPosition
                timer.invalidate()
                return
            }
            
            let t = SIMD3<Float>(repeating: Float(elapsedTime / action.duration))
            self.position = simd_mix(startPosition, action.targetPosition, t)
        }
        
        // Keep timer referenced
        RunLoop.main.add(timer, forMode: .common)
    }
}
