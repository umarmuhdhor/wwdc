
import SwiftUI

struct ShipPartButton: View {
    let part: ShipPart
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(part.previewImageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                
                Text(part.name)
                    .foregroundColor(.white)
            }
        }
        .disabled(part.isPlaced)
        .opacity(part.isPlaced ? 0.5 : 1)
    }
}
