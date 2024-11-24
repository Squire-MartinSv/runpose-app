//
//  Styles.swift
//  runpose
//
//  Created by Martin Svadlenka on 12.11.2024.
//
import SwiftUI

public struct PurpleButtonStyle: ButtonStyle {
    public init(){}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .font(.body) // Adjust font settings if necessary
            .background(
                RoundedRectangle(cornerRadius: 10) // Apply corner radius here
                    .fill(Color.purple) // Background color with opacity
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct YellowButtonStyle: ButtonStyle {
    public init(){}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .font(.body) // Adjust font settings if necessary
            .background(
                RoundedRectangle(cornerRadius: 10) // Apply corner radius here
                    .fill(Color.yellow) // Background color with opacity
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

public struct GreyButtonStyle: ButtonStyle {
    public init(){}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .font(.body) // Adjust font settings if necessary
            .background(
                RoundedRectangle(cornerRadius: 10) // Apply corner radius here
                    .fill(Color.gray) // Background color with opacity
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

