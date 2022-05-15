import Inject
import MathParser
import PencilKit
import SwiftUI

struct HomeView: View {
    @ObserveInjection var inject
    @ObservedObject var viewModel = HomeViewModel()

    @State private var canvasView = PKCanvasView()

    var body: some View {
        VStack {
            AttributedText($viewModel.content)
            CanvasView(canvasView: $canvasView, onSaved: saveDrawing)
        }
        .enableInjection()
    }

    func saveDrawing() {}
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
