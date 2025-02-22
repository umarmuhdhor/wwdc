import SwiftUI
import RealityKit
import ARKit
import Combine

final class ARViewModel: ObservableObject {
    @Published var placedParts = 0
    @Published var selectedPartId: Int?
    @Published var scanningFloor = true
    @Published var availableParts: [ShipPart] = ShipPart.defaultParts()
    
    let totalParts = 6
    weak var arView: ARView?
    private var shipGuidelineAnchor: AnchorEntity?
    private var shipGuidelineEntity: ModelEntity?
    
    func handlePlaneDetection(_ planeAnchor: ARPlaneAnchor) {
        DispatchQueue.main.async {
            self.scanningFloor = false
            self.createShipGuideline(at: planeAnchor.transform)
        }
    }
    
    private func createShipGuideline(at transform: simd_float4x4) {
        guard let arView = arView else { return }
        
        shipGuidelineAnchor?.removeFromParent()
        let anchor = AnchorEntity(world: transform)
        
        do {
            let shipModel = try ModelEntity.loadModel(named: "ship")
            shipModel.scale = [1, 1, 1]
            shipModel.position = [0, 0, 0]
                    
            var material = SimpleMaterial()
            material.baseColor = .init(_colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            material.roughness = .init(floatLiteral: 0.8)
            material.metallic = .init(floatLiteral: 0.0)
            shipModel.model?.materials = [material]
                    
            anchor.addChild(shipModel)
            shipGuidelineEntity = shipModel
        } catch {
            print("Failed to load ship model: \(error)")
        }
        
        arView.scene.addAnchor(anchor)
        shipGuidelineAnchor = anchor
    }
    
    func selectPart(_ part: ShipPart) {
        selectedPartId = part.id
    }
    
    func handleTap(at transform: simd_float4x4) {
        guard let selectedId = selectedPartId,
              let part = availableParts.first(where: { $0.id == selectedId && !$0.isPlaced }),
              let anchor = shipGuidelineAnchor else { return }
        
        do {
            let entity = try ModelEntity.load(named: part.modelName)
            entity.position = part.position
            entity.orientation = part.rotation
            
            anchor.addChild(entity)
            
            if let index = availableParts.firstIndex(where: { $0.id == selectedId }) {
                availableParts[index].isPlaced = true
            }
            
            placedParts += 1
            selectedPartId = nil
            
        } catch {
            print("Failed to load part model: \(error)")
        }
    }
    
    func resetGame() {
        guard let arView = arView else { return }
        arView.scene.anchors.removeAll()
        
        placedParts = 0
        selectedPartId = nil
        scanningFloor = true

        availableParts = ShipPart.defaultParts().map { part in
            var newPart = part
            newPart.isPlaced = false
            return newPart
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
    }
}
