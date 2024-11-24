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
            comment = "The knee angle reflects the range of motion in the left knee during the activity. For optimal performance and joint safety, the maximum angle should not exceed 170 degrees, as a fully straightened knee can transfer ground impact directly and more forcefully to the knee joint. Conversely, the minimum angle should not drop below 90 degrees to maintain an ideal balance between knee flexion and speed."
            if maxAngle > 170 {
                recommendations.append("The analyzed maximum angle exceeds 170 degrees, which could lead to issues. Consider keeping your leg slightly bent when ground contact to reduce the risk of knee fatigue or discomfort.")
                showWarning = true
            }
            if minAngle < 90 {
                recommendations.append("The analyzed minimum angle falls below 90 degrees, which may reduce speed and increase strain on your leg muscles. Aim to keep the minimum knee angle above 90 degrees at the most bent point to promote balanced and efficient movement.")
                showWarning = true
            }
        // Right knee angle logic
        case "Right Knee Angles":
            comment = "The knee angle reflects the range of motion in the right knee during the activity. For optimal performance and joint safety, the maximum angle should not exceed 170 degrees, as a fully straightened knee can transfer ground impact directly and more forcefully to the knee joint. Conversely, the minimum angle should not drop below 90 degrees to maintain an ideal balance between knee flexion and speed."
            if maxAngle > 170 {
                recommendations.append("The analyzed maximum angle exceeds 170 degrees, which could lead to issues. Consider keeping your leg slightly bent when ground contact to reduce the risk of knee fatigue or discomfort.")
                showWarning = true
            }
            if minAngle < 90 {
                recommendations.append("The analyzed minimum angle falls below 90 degrees, which may reduce speed and increase strain on your leg muscles. Aim to keep the minimum knee angle above 90 degrees at the most bent point to promote balanced and efficient movement.")
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
            comment = "The Body Lean Angle measures your forward tilt while running, relative to a vertical axis, with 0 degrees being perfectly upright. An ideal lean is 10–15 degrees, initiated from the ankles, allowing gravity to assist motion and reducing leg strain. Excessive or insufficient lean can impact speed and efficiency. Avoid bending from the waist or leaning backward to prevent inefficiency and increased impact forcesLeaning more increases speed, while leaning less slows you down."
            if maxAngle > 20 {
                recommendations.append("Your maximum Body lean angle exceeds 20 degrees, which may cause instability and strain. Aim to maintain a forward lean of 10–15 degrees for optimal efficiency and balance.")
                showWarning = true
            }
            if minAngle < 5 {
                recommendations.append("Your minimum analysed Body lean angle is less than 5 degrees, which may reduce efficiency, increase leg strain and slow down your speed. Aim for a forward lean of 10–15 degrees to improve balance and running performance.")
                showWarning = true
            }
        
        // head horizonatla angle logic
        case "Head Horizontal Angles":
            comment = "The head horizontal angle measures the tilt of your head while running, with 0 degrees indicating your eyes are level and looking straight ahead—considered the ideal position. The optimal range is between -5 and 15 degrees. Positive angles indicate your head is tilted upward above the horizontal axis, while negative angles suggest your head is tilted downward."
            if maxAngle > 15 {
                recommendations.append("Avoid tilting your head backward while running, as it can strain your neck and upper spine, disrupt balance, and misalign your posture. This position reduces efficiency and increases the risk of discomfort. Keep your head neutral, with your eyes focused forward, to maintain proper alignment and efficiency.")
                showWarning = true
            }
            if minAngle < -5 {
                recommendations.append("Focus on keeping your head straight while running. Looking downward can cause the body to bend at the waist, leading to a folding posture that reduces efficiency and disrupts alignment. Keeping your gaze forward ensures proper posture and balance during running.")
                showWarning = true
            }
        default:
            comment = "No specific comment available."
        }
        
        return AngleInfo(comment: comment, recommendations: recommendations, showWarning: showWarning)
    }
}

