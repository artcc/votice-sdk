//
//  HeaderView.swift
//  VoticeDemo
//
//  Created by Arturo Carretero Calvo on 30/7/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    // MARK: - View

    var body: some View {
        VStack(spacing: 10) {
            Image("image")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            Text("Test all the feedback features")
                .font(.poppins(.regular, size: 16))
                .foregroundColor(.secondary)
        }
    }
}
