

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: PageModel
    
    var body: some View {
        VStack {
            if (model.state == .Start){
                FrontPage(model: self.model)
            } else if (model.state == .Game){
                GameView(model: self.model)
            } else if (model.state == .End){
                EndPage(model: self.model)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: PageModel())
    }
}
