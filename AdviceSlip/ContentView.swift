//
//  ContentView.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Advice.id, order: .forward)
    var advices: [Advice]
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! Total: \(advices.count)")
            List {
                ForEach(advices) { advice in
                    VStack(alignment: .leading) {
                        Text("#\(advice.id)")
                        Text(advice.advice)
                    }
                }
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
