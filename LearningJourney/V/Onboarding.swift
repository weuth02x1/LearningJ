//
//  Onboarding.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447 AH.
//
import SwiftUI
import Combine

struct Onboarding: View {
    @State var learningTopic = ""
    @State private var selectedPeriod: String = "Week"
    @State private var moveToMain = false

    @State private var selectedViewModel: StreakViewModel? = nil

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // MARK: - Circle flame icon
                    ZStack { Circle() .
                        fill(Color("#613814")
                            .opacity(0.2)) .background( Circle() .fill(Color.black.opacity(0.8)) .blur(radius: 62) .blendMode(.softLight) .blendMode(.overlay)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.6),
                                                Color.orange.opacity(0.3),
                                                Color.black.opacity(0.2)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 5, y: 8)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                    .blur(radius: 3)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle())
                            )
                            .frame(width: 109, height: 109)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(red: 255/255, green: 146/255, blue: 48/255))
                    }
                    .padding(.top, 90)
                    
                    // MARK: - Text + Input
                    VStack(alignment: .leading) {
                        Text("Hello Learner")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("This app will help you learn everyday!")
                            .foregroundColor(.gray)
                            .padding(.bottom, 30)
                        
                        Text("I want to learn ")
                            .foregroundColor(.white)
                            .font(.title3.bold())
                        
                        ZStack(alignment: .leading) {
                            if learningTopic.isEmpty {
                                Text("Write your goal here")
                                    .foregroundColor(Color.gray)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                            }
                            
                            TextField("", text: $learningTopic)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                        }
                        
                        Rectangle()
                            .frame(height: 0.7)
                            .foregroundColor(Color.gray.opacity(0.4))
                            .padding(.bottom, 30)
                        
                        Text("I want to learn it in a ")
                            .padding(.bottom, 8)
                            .foregroundColor(.white)
                            .font(.title3.bold())
                        
                        // MARK: - Period buttons
                        HStack(spacing: 8) {
                            Button("Week") { selectedPeriod = "Week" }
                                .applySelection(isSelected: selectedPeriod == "Week")
                            Button("Month") { selectedPeriod = "Month" }
                                .applySelection(isSelected: selectedPeriod == "Month")
                            Button("Year") { selectedPeriod = "Year" }
                                .applySelection(isSelected: selectedPeriod == "Year")
                        }

                        // MARK: - Start button
                        Button(action: {
                            guard !learningTopic.trimmingCharacters(in: .whitespaces).isEmpty else { return }

                            // 🟠 إنشاء ViewModel
                            let duration = StreakViewModel.durationFromString(selectedPeriod)
                            let vm = StreakViewModel(duration: duration)

                            // 🟢 خزني قيمة الـ topic داخل الـ manager مباشرة
                            vm.learningTopic = learningTopic

                            // 🟢 خزّني في selectedViewModel عشان تمر لواجهة Main
                            vm.resetStreak()  // ← هذا السطر هو اللي يسوي restart للستريك
                            selectedViewModel = vm

                            // 🔵 بعدين فعّلي الانتقال
                            moveToMain = true
                        }) {
                            Text("Start Learning")
                                .frame(width: 182, height: 48)
                                                                  .fontWeight(.bold)
                                                                  .foregroundColor(.white)
                                                                  .glassEffect(.clear.tint(Color(hex: "#FF9230").opacity(0.9)))
                                                                  .clipShape(Capsule())
                                                          }
                                                          .padding(.top, 150)
                                                          .padding(.horizontal, 80)
                                                          .disabled(learningTopic.trimmingCharacters(in: .whitespaces).isEmpty)
                                                          .opacity(learningTopic.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
                        }


                        // MARK: - Navigation Destination
                        .navigationDestination(isPresented: $moveToMain) {
                            if let vm = selectedViewModel {
                                MainView(manager: vm)
                                    .navigationBarBackButtonHidden(true)
                            }
                        }


                        

                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    
    
    

// HEX Color helper
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension View {
    func applySelection(isSelected: Bool) -> some View {
        self
            .fontWeight(.bold)
            .frame(width: 97, height: 48)
            .foregroundColor(.white)
            .glassEffect(.clear.tint(isSelected ? Color(hex: "#FF9230").opacity(0.9) : Color(hex: "#262626").opacity(0.40)))
            .buttonStyle(.plain)
    }
}

#Preview {
    Onboarding()
}
