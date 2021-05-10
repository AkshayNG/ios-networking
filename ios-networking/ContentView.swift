//
//  ContentView.swift
//  ios-networking
//
//  Created by Akshay Gajarlawar on 09/05/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Text("Hello, world!")
                .padding()
        }.onAppear{
            self.testDataEncoding()
            self.makeAPIRequest()
        }
    }
    
    func testDataEncoding() {
        let gist = Gist.init(id: nil, isPublic: true, description: "Hello World!")
        do {
            let gistData = try JSONEncoder().encode(gist)
            let gistString = String(data: gistData, encoding: .utf8)
            print(gistString ?? "No String!")
        } catch let error {
            print("Encoding Error: \(error.localizedDescription)")
        }
    }
    
    func makeAPIRequest() {
        DataService.shared.fetchGists { (result) in
            switch result {
            
            case .success(let gists):
                gists.forEach { print("\($0) \n") }
                
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
