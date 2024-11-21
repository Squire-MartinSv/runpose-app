//
//  AngleInfoProvider.swift
//  runpose
//
//  Created by Martin Svadlenka on 21.11.2024.
//
import Foundation
import SwiftUI

struct AngleInfo {
    let comment: String
    let recommendations: [String]
    let showWarning: Bool
}

class AngleInfoProvider {
    static func getInfo(for angleType: String, minAngle: Double, maxAngle: Double, recommendedRange: (min: Double, max: Double)) -> AngleInfo {
        var comment: String
        var recommendations: [String] = []
        var showWarning = false
        
        switch angleType {
        // Left knee angle
        case "Left Knee Angles":
            comment = "The knee angle reflects the range of motion in the left knee during the activity. For optimal performance and joint safety, the maximum angle should not exceed 170 degrees, as a fully straightened knee can transfer ground impact directly and more forcefully to the knee joint. Conversely, the minimum angle should not drop below 45 degrees to maintain an ideal balance between knee flexion and speed."
            if maxAngle > 170 {
                recommendations.append("The analyzed maximum angle exceeds 170 degrees, which could lead to issues. Consider keeping your leg slightly bent when ground contact to reduce the risk of knee fatigue or discomfort.")
                showWarning = true
            }
            if minAngle < 90 {
                recommendations.append("The analyzed minimum angle falls below 45 degrees, which may reduce speed and increase strain on your leg muscles. Aim to keep the angle above 45 degrees at the most bent point to promote balanced and efficient movement.")
                showWarning = true
            }
        // Right knee angle logic
        case "Right Knee Angles":
            comment = "The knee angle reflects the range of motion in the right knee during the activity. For optimal performance and joint safety, the maximum angle should not exceed 170 degrees, as a fully straightened knee can transfer ground impact directly and more forcefully to the knee joint. Conversely, the minimum angle should not drop below 45 degrees to maintain an ideal balance between knee flexion and speed."
            if maxAngle > 170 {
                recommendations.append("The analyzed maximum angle exceeds 170 degrees, which could lead to issues. Consider keeping your leg slightly bent when ground contact to reduce the risk of knee fatigue or discomfort.")
                showWarning = true
            }
            if minAngle < 90 {
                recommendations.append("The analyzed minimum angle falls below 45 degrees, which may reduce speed and increase strain on your leg muscles. Aim to keep the angle above 45 degrees at the most bent point to promote balanced and efficient movement.")
                showWarning = true
            }
            
        //LEFT elbow logic
        case "Left Elbow Angles":
            comment = "The elbow angle reflects the range of motion in the left arm during activity. For optimal performance, it should remain between 80 and 120 degrees. Tighter angles suit sprints, aiding faster arm turnover, while wider angles offer comfort for long races but may reduce efficiency. A balanced range ensures smooth and effective arm movement."
            if maxAngle > 120 {
                recommendations.append("The analyzed minimum elbow angle exceeds 120 degrees. While an elbow angle of around 90 degrees is generally recommended, angles up to 120 degrees can provide greater comfort during long-distance races, despite the slight increase in air resistance. Over 120 degress is not recommended due to increased risk of back discomfort.")
                showWarning = true
            }
            if minAngle < 80 {
                recommendations.append("The analyzed minimum elbow angle drops below 80 degrees. While lower angles can be effective for sprinters in short-distance races due to their tighter arm swing and faster turnover, they may cause discomfort or inefficiency during longer distances. Generally, an elbow angle of around 90 degrees is recommended, as it balances comfort, energy efficiency, and smooth arm movement for most runners.")
                showWarning = true
            }
            
        // RIGHT elbow logic
        case "Right Elbow Angles":
            comment = "The elbow angle reflects the range of motion in the right arm during activity. For optimal performance, it should remain between 80 and 120 degrees. Tighter angles suit sprints, aiding faster arm turnover, while wider angles offer comfort for long races but may reduce efficiency. A balanced range ensures smooth and effective arm movement."
            if maxAngle > 120 {
                recommendations.append("The analyzed minimum elbow angle exceeds 120 degrees. While an elbow angle of around 90 degrees is generally recommended, angles up to 120 degrees can provide greater comfort during long-distance races, despite the slight increase in air resistance. Over 120 degress is not recommended due to increased risk of back discomfort.")
                showWarning = true
            }
            if minAngle < 80 {
                recommendations.append("The analyzed minimum elbow angle drops below 80 degrees. While lower angles can be effective for sprinters in short-distance races due to their tighter arm swing and faster turnover, they may cause discomfort or inefficiency during longer distances. Generally, an elbow angle of around 90 degrees is recommended, as it balances comfort, energy efficiency, and smooth arm movement for most runners.")
                showWarning = true
            }
            
        // body lean angle logc
        case "Body Lean Angles":
            comment = ""
            if abs(maxAngle - minAngle) > 45 {
                recommendations.append("")
                showWarning = true
            }
        case "Head Horizontal Angles":
            comment = ""
            if minAngle < recommendedRange.min || maxAngle > recommendedRange.max {
                recommendations.append("A")
                showWarning = true
            }
        default:
            comment = "No specific comment available."
        }
        
        return AngleInfo(comment: comment, recommendations: recommendations, showWarning: showWarning)
    }
}

