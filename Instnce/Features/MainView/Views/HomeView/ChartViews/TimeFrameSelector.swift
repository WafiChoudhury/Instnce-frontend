//
//  TimeFrameSelector.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/28/25.
//

import SwiftUI

// Shared timeframe enum
public enum Timeframe: String, CaseIterable {
    case d1 = "1D", w1 = "1W", m1 = "1M", m3 = "3M", y1 = "1Y", y5 = "5Y"
}

// Reusable selector component
struct TimeFrameSelector: View {
    @Binding var selectedTimeframe: Timeframe
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Timeframe.allCases, id: \.self) { tf in
                Button(tf.rawValue) {
                    withAnimation(.easeInOut(duration: 0.15)) { selectedTimeframe = tf }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(selectedTimeframe == tf ? Color(.systemBackground) : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTimeframe == tf ? Color.accentColor : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: selectedTimeframe == tf ? 0 : 1)
                        )
                )
            }
            Spacer(minLength: 0)
        }
    }
}

