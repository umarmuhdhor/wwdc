import SwiftUI
import RealityKit
import ARKit
import Combine

// MARK: - Ship Part Definition
struct ShipPart: Identifiable {
    let id: Int
    let name: String
    let modelName: String // Nama file USDZ
    let position: SIMD3<Float>
    let rotation: simd_quatf
    var isPlaced: Bool = false
    
    // Predefined positions and rotations for each part
    static let defaultParts = [
        ShipPart(id: 1,
                 name: "Base",
                 modelName: "ship_base",
                 position: SIMD3<Float>(0, 0, 0),
                 rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))),
        ShipPart(id: 2,
                 name: "Middle",
                 modelName: "ship_middle",
                 position: SIMD3<Float>(0, 0.2, 0),
                 rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))),
        ShipPart(id: 3,
                 name: "Top",
                 modelName: "ship_top",
                 position: SIMD3<Float>(0, 0.4, 0),
                 rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))),
        ShipPart(id: 4,
                 name: "Left Wing",
                 modelName: "ship_left_wing",
                 position: SIMD3<Float>(-0.2, 0.2, 0),
                 rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))),
        ShipPart(id: 5,
                 name: "Right Wing",
                 modelName: "ship_right_wing",
                 position: SIMD3<Float>(0.2, 0.2, 0),
                 rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0)))
    ]
}

// MARK: - Updated AR ViewModel
class ARViewModel: ObservableObject {
    @Published var placedParts = 0
    @Published var selectedPartId: Int?
    @Published var scanningFloor = true
    @Published var availableParts: [ShipPart] = []
    
    let totalParts = 5
    weak var arView: ARView?
    private var shipGuidelineAnchor: AnchorEntity?
    private var loadedModels: [String: ModelEntity] = [:]
    
    init() {
        setupParts()
        preloadModels()
    }
    
    private func setupParts() {
        availableParts = ShipPart.defaultParts
    }
    
    private func preloadModels() {
        for part in availableParts {
            loadModel(named: part.modelName) { [weak self] entity in
                self?.loadedModels[part.modelName] = entity
            }
        }
    }
    
    private func loadModel(named name: String, completion: @escaping (ModelEntity?) -> Void) {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "usdz") else {
            print("Failed to find model: \(name)")
            completion(nil)
            return
        }
        
        do {
            let entity = try ModelEntity.loadModel(contentsOf: modelURL)
            entity.generateCollisionShapes(recursive: true)
            completion(entity)
        } catch {
            print("Failed to load model \(name): \(error)")
            completion(nil)
        }
    }
    
    private func createGuidelineEntity(for part: ShipPart) -> ModelEntity? {
        guard let originalModel = loadedModels[part.modelName] else { return nil }
        
        // Create semi-transparent copy of the model
        let guidelineEntity = originalModel.clone(recursive: true)
        
        // Make it semi-transparent
        if var material = guidelineEntity.model?.materials.first as? SimpleMaterial {
            material.baseColor = MaterialColorParameter.color(.white.withAlphaComponent(0.3))
            guidelineEntity.model?.materials = [material]
        }
        
        return guidelineEntity
    }
    
    func createShipGuideline(at transform: simd_float4x4) {
        guard let arView = arView else { return }
        
        shipGuidelineAnchor?.removeFromParent()
        
        let anchor = AnchorEntity(world: transform)
        
        // Add guidelines for each part
        for part in availableParts {
            if let guidelineEntity = createGuidelineEntity(for: part) {
                guidelineEntity.position = part.position
                guidelineEntity.orientation = part.rotation
                anchor.addChild(guidelineEntity)
            }
        }
        
        arView.scene.addAnchor(anchor)
        shipGuidelineAnchor = anchor
    }
    
    func handleTap(at transform: simd_float4x4) {
        guard let selectedId = selectedPartId,
              let part = availableParts.first(where: { $0.id == selectedId && !$0.isPlaced }),
              let anchor = shipGuidelineAnchor,
              let modelEntity = loadedModels[part.modelName]?.clone(recursive: true) else { return }
        
        // Position the part
        modelEntity.position = part.position
        modelEntity.orientation = part.rotation
        
        // Add visual feedback
        addPlacementEffect(to: modelEntity)
        
        anchor.addChild(modelEntity)
        
        if let index = availableParts.firstIndex(where: { $0.id == selectedId }) {
            availableParts[index].isPlaced = true
        }
        
        placedParts += 1
        selectedPartId = nil
    }
    
    private func addPlacementEffect(to entity: ModelEntity) {
        // Tambahkan efek visual saat penempatan
        // Contoh: scale animation
        entity.scale = SIMD3<Float>(0.8, 0.8, 0.8)
        
        var transform = entity.transform
        transform.scale = SIMD3<Float>(1, 1, 1)
        
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeInOut)
    }
    
    func resetGame() {
        guard let arView = arView else { return }
        
        // Reset AR scene
        arView.scene.anchors.removeAll()
        
        // Reset game state
        placedParts = 0
        selectedPartId = nil
        scanningFloor = true
        
        // Reset parts
        setupParts()
        
        // Reset AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
    }
}

// MARK: - Updated Ship Part Button
struct ShipPartButton: View {
    let part: ShipPart
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 60, height: 60)
                    
                    // Preview image dari model
                    Image(part.modelName + "_preview")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                
                Text(part.name)
                    .foregroundColor(.white)
            }
        }
        .disabled(part.isPlaced)
        .opacity(part.isPlaced ? 0.5 : 1)
    }
}
