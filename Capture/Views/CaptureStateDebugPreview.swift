#if DEBUG
import SwiftUI

struct CaptureStateDebugPreview: View {
    @State private var model = CaptureViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text(model.state.rawValue)
                .font(.title2)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                    ForEach(CaptureState.allCases, id: \.self) { state in
                        Button(state.rawValue) {
                            model.debugSetState(state)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview("Capture states") {
    CaptureStateDebugPreview()
}
#endif
