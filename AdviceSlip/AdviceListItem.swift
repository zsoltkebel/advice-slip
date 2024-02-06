//
//  AdviceListItem.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import SwiftUI

struct AdviceListItem: View {
    var advice: Snippet
    
    var body: some View {
        HStack {
            Text(advice.content)
            Spacer(minLength: 10)
            Text("#\(advice.sourceID)")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        List {
            AdviceListItem(advice: .preview)
        }
    }
}
