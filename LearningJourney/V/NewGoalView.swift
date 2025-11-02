//
//  NewGoalView.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447 AH.

import SwiftUI
import Combine


struct NewGoalView: View {
    @ObservedObject var manager: StreakViewModel
    @State var learningTopic: String
    @State private var selectedPeriod: String
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckmark = false

    init(manager: StreakViewModel, learningTopic: String, initialPeriod: String) {
        self.manager = manager
        self._learningTopic = State(initialValue: learningTopic)
        self._selectedPeriod = State(initialValue: initialPeriod)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // ======= Header =======
                HStack {
                    // زر الرجوع
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                            )
                            .glassEffect(.regular.interactive())
                    }

                    Spacer()

                    // ✅ زر الحفظ (checkmark) يظهر فقط عند التغيير
                    if showCheckmark {
                        Button(action: {
                            manager.learningTopic = learningTopic
                            manager.duration = StreakViewModel.durationFromString(selectedPeriod)
                            manager.resetStreak()

                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle().fill(Color(red: 0.65, green: 0.22, blue: 0.00))
                                )
                                .overlay(
                                    Circle().stroke(
                                        LinearGradient(
                                            colors: [.yellow.opacity(0.45), .orange.opacity(0.65)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                                )
                                .shadow(color: .orange.opacity(0.25), radius: 5, x: 0, y: 2)
                                .glassEffect(.regular.interactive())
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .frame(height: 60)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showCheckmark)

                // ======= المحتوى =======
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Learning Goal")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Text("I want to learn")
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        TextField("Your goal", text: $learningTopic)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.7)
                                    .foregroundColor(.gray.opacity(0.4)),
                                alignment: .bottom
                            )
                            .padding(.bottom, 20)
                            .onChange(of: learningTopic) { newValue in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showCheckmark = !newValue.trimmingCharacters(in: .whitespaces).isEmpty
                                }
                            }

                        Text("I want to learn it in a")
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            ForEach(["Week", "Month", "Year"], id: \.self) { period in
                                Button(period) {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedPeriod = period
                                        showCheckmark = true // ← يظهر الزر لو غيّر المدة
                                    }
                                }
                                .applySelection(isSelected: selectedPeriod == period)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
        }
    }
}
