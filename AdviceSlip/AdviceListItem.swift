//
//  AdviceListItem.swift
//  AdviceSlip
//
//  Created by Zsolt Kébel on 31/01/2024.
//

import SwiftUI

struct AdviceListItem: View {
    var advice: Advice
    
    var body: some View {
        HStack {
            Text(advice.advice)
            Spacer(minLength: 10)
            Text("#\(advice.id)")
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
