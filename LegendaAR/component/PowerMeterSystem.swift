import RealityKit
import UIKit

class PowerMeterSystem {
    // Power meter entities
    private var meterBackground: ModelEntity?
    private var powerIndicator: ModelEntity?
    
    // Power meter state
    private var powerLevel: Float = 0
    private var powerIncreasing = true
    private var powerMeterTimer: Timer?
    
    // Callback for when shot is performed
    private var onShot: ((Float) -> Void)?
    
    // State tracking
    var isActive: Bool = false
    
    // Create and show the power meter
    func create(nearEntity entity: Entity, inAnchor anchor: AnchorEntity, onShot: @escaping (Float) -> Void) {
        // Save callback
        self.onShot = onShot
        
        // Create power meter background (gray bar)
        let meterWidth: Float = 0.5
        let meterHeight: Float = 0.05
        
        meterBackground = ModelEntity(
            mesh: .generatePlane(width: meterWidth, height: meterHeight),
            materials: [SimpleMaterial(color: .lightGray, isMetallic: false)]
        )
        
        // Create power level indicator (colored bar)
        powerIndicator = ModelEntity(
            mesh: .generatePlane(width: 0.01, height: meterHeight),
            materials: [SimpleMaterial(color: .yellow, isMetallic: false)]
        )
        
        guard let meterBackground = meterBackground,
              let powerIndicator = powerIndicator else {
            return
        }
        
        // Position power meter above the entity
        let entityPosition = entity.position
        meterBackground.position = SIMD3<Float>(
            entityPosition.x,
            entityPosition.y + 0.5,
            entityPosition.z
        )
        
        // Initial position of power indicator (at left edge)
        powerIndicator.position = SIMD3<Float>(
            -meterWidth/2 + 0.005, // Slight offset to be visible
            0,
            -0.001 // Slightly in front
        )
        
        // Add indicator to background
        meterBackground.addChild(powerIndicator)
        
        // Add to scene
        anchor.addChild(meterBackground)
        
        // Start power meter animation
        startPowerMeterAnimation(maxWidth: meterWidth)
        
        isActive = true
    }
    
    // Start the power meter animation
    private func startPowerMeterAnimation(maxWidth: Float) {
        // Reset power level
        powerLevel = 0
        powerIncreasing = true
        
        // Start power meter animation
        powerMeterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self,
                  let powerIndicator = self.powerIndicator else {
                return
            }
            
            // Update power level
            if self.powerIncreasing {
                self.powerLevel += 0.02
                if self.powerLevel >= 1.0 {
                    self.powerLevel = 1.0
                    self.powerIncreasing = false
                }
            } else {
                self.powerLevel -= 0.02
                if self.powerLevel <= 0 {
                    self.powerLevel = 0
                    self.powerIncreasing = true
                }
            }
            
            // Update power meter width
            let currentWidth = maxWidth * self.powerLevel
            
            // Update mesh
            powerIndicator.model?.mesh = .generatePlane(width: currentWidth, height: 0.05)
            
            // Update position (align left edge)
            powerIndicator.position.x = -maxWidth/2 + currentWidth/2
            
            // Update color based on power level
            let color: UIColor
            if self.powerLevel < 0.3 {
                // Yellow zone (too weak)
                color = .yellow
            } else if self.powerLevel > 0.7 {
                // Red zone (too strong)
                color = .red
            } else {
                // Green zone (just right)
                color = .green
            }
            
            powerIndicator.model?.materials = [SimpleMaterial(color: color, isMetallic: false)]
        }
        
        // Add tap gesture to meter to "lock in" power
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Add tap recognizer to power meter
            if let meterBackground = self.meterBackground {
                meterBackground.collision = CollisionComponent(shapes: [.generateBox(size: [0.5, 0.1, 0.1])])
                
                // Subscribe to tap events
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.powerMeterTapped),
                    name: NSNotification.Name("PowerMeterTapped"),
                    object: nil
                )
            }
        }
    }
    
    // Handle tap on power meter
    @objc func powerMeterTapped() {
        guard isActive else { return }
        
        // Stop animation
        powerMeterTimer?.invalidate()
        powerMeterTimer = nil
        
        // Execute callback with final power
        onShot?(powerLevel)
        
        // Remove power meter
        cleanup()
    }
    
    // Clean up resources
    func cleanup() {
        meterBackground?.removeFromParent()
        meterBackground = nil
        powerIndicator = nil
        isActive = false
        
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
    }
}
