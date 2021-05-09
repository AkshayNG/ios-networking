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
        }.onAppear{ self.makeAPIRequest() }
    }
    
    func makeAPIRequest() {
        DataService.shared.fetchGists { (result) in
            switch result {
            
            case .success(let json):
                print("API Data: \(json)")
                
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
