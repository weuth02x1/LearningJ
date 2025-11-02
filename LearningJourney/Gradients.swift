//
//  Gradients.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447 AH.
//
import SwiftUI

enum Gradients {
    static let learnDefault = LinearGradient(colors: [
        Color(red: 165/255, green: 61/255, blue: 20/255),
        Color(red: 0.7, green: 0.3, blue: 0.1)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    
    static let learned = LinearGradient(colors: [
        Color.orange.opacity(0.08),
        Color(red: 260/255, green: 64/255, blue: 3/255, opacity: 0.08)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    static let freezed = LinearGradient(colors: [
        Color(red: 0/255, green: 97/255, blue: 106/255, opacity: 0.08),
        Color(red: 0/255, green: 97/255, blue: 106/255, opacity: 0.08)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    static let strokeDefault = LinearGradient(colors: [
        Color(red: 224/255, green: 191/255, blue: 138/255),
        Color(red: 174/255, green: 98/255, blue: 31/255),
        Color(red: 239/255, green: 151/255, blue: 72/255)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    static let strokeLearned = LinearGradient(colors: [
        Color(red: 202/255, green: 177/255, blue: 151/255),
        Color(red: 46/255, green: 13/255, blue: 3/255),
        Color(red: 92/255, green: 59/255, blue: 28/255)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    static let strokeFreezed = LinearGradient(colors: [
        Color(red: 83/255, green: 153/255, blue: 157/255),
        Color(red: 0/255, green: 25/255, blue: 36/255),
        Color(red: 0/255, green: 97/255, blue: 107/255)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    static let freezeNormal = LinearGradient(colors: [
        Color(red: 0.2, green: 0.6, blue: 0.7),
        Color(red: 0.1, green: 0.4, blue: 0.5)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    static let freezePressed = LinearGradient(colors: [
        Color(red: 0.05, green: 0.1, blue: 0.1),
        Color(red: 0.1, green: 0.15, blue: 0.17)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)

    static let capsuleStroke = LinearGradient(colors: [
        .white.opacity(0.4), .black.opacity(0.2)
    ], startPoint: .topLeading, endPoint: .bottomTrailing)
}
