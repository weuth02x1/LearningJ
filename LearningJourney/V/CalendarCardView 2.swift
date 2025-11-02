//
//  CalendarCardView 2.swift
//  LearningJ
//
//  Created by Shahd Abdullah on 06/05/1447 AH.
//

import SwiftUI

struct CalendarCardView: View {
    @ObservedObject var manager: StreakViewModel
    var learningTopic: String
       @State private var showMonthPicker: Bool = false
       @State private var currentDate = Date()
   
        let cal = Calendar.current
       private var days: [Date] {
           WeakDaysHelper.weekDays(for: currentDate)
       }
   
       private var monthText: String {
           WeakDaysHelper.monthFmt.string(from: currentDate)
       }
       private var monthYearText: String {
              let f = DateFormatter(); f.dateFormat = "LLLL yyyy"
              return f.string(from: currentDate)
          }
    private let weekDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E" // يعطي Mon, Tue, Wed...
        return f
    }()



  

    private var weekDays: [Date] {
        guard let interval = cal.dateInterval(of: .weekOfYear, for: currentDate) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: interval.start) }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial.opacity(0.2))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12)))
                .padding()
                .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 18)
            VStack(spacing: 16) {
                // MARK: Header (الشهر والسنة + الأسهم)
                HStack(spacing: 8) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showMonthPicker.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(monthYearText)
//                                .padding(.horizontal)
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: showMonthPicker ? "chevron.up" : "chevron.down")
                                .foregroundColor(.orange)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }

                    Spacer()

                    Button { moveWeek(-1) } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.trailing, 10)

                    Button { moveWeek(+1) } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.orange)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 36)
                

                // MARK: Weekdays Row (SUN–SAT + دوائر)
                HStack(spacing: 10) {
                    ForEach(days, id: \.self) { date in
                        let day = cal.startOfDay(for: date)
                        let isLearned = manager.learnedDates.contains(day)
                        let isFreezed = manager.freezedDates.contains(day)
                        let isToday = cal.isDateInToday(date)
                        
//                        VStack(spacing: 6) {
//                            Text(WeakDaysHelper.dayFmt.string(from: date).uppercased())
//                                .font(.system(size: 12, weight: .semibold))
//                                .foregroundColor(.gray)

                        VStack(spacing: 6) {
                            Text(weekDayFormatter.string(from: date).uppercased())
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        


                            Circle()
                                .fill(isFreezed ? Color.cyan.opacity(0.4) :
                                      isLearned ? Color.orange.opacity(0.4) :
                                      isToday ? .orange :
                                        Color.clear)
                                
                                .frame(width: 43, height: 43)
                                .overlay(
                                    Text(WeakDaysHelper.dayFmt.string(from: date))
                                    .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(
                                            isFreezed ? Color.cyan :
                                            isLearned ? Color.orange :
                                            isToday ? Color.white :
                                            .white)
                                )
                        }
                    }
                }
                .padding(.horizontal, 26)

                Divider()
                    .background(Color.white.opacity(0.18))
                    .padding(.horizontal, 30)

                // MARK: - محتوى الكارد (الإحصائيات أو البيكر)
                if showMonthPicker {
                    VStack {
                        MonthYearMergedWheel(date: $currentDate)
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            .transition(.opacity.combined(with: .slide))
                            .animation(.easeInOut(duration: 0.3), value: showMonthPicker)
                    }
                    .padding(.horizontal, 16)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Learning \(learningTopic)")
                            .foregroundColor(.white)
//                            .padding(.horizontal)
                            .font(.system(size: 16, weight: .semibold))

                        HStack(spacing: 12) {
                            statCard(icon: "flame.fill",
                                     color:.orange.opacity(0.8),
                                     value: manager.streakDays,
                                     text: manager.streakDays == 1 ? "Day Learned" : "Days Learned")

                            statCard(icon: "cube.fill",
                                     color: .cyan.opacity(0.8),
                                     value: manager.freezesUsed,
                                     text: manager.freezesUsed == 1 ? "Day Freezed" : "Days Freezed")
                        }
                    }
                    .padding(.horizontal, 26)
                    .transition(.opacity.combined(with: .slide))
                    .animation(.easeInOut(duration: 0.3), value: showMonthPicker)
                }

                Spacer(minLength: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding(.horizontal, 16)
    }
       private func moveWeek(_ offset: Int) {
            if let newDate = cal.date(byAdding: .weekOfYear, value: offset, to: currentDate) {
                currentDate = newDate
            }
        }

    private func moveMonth(_ offset: Int) {
        if let newDate = cal.date(byAdding: .month, value: offset, to: currentDate) {
            currentDate = newDate
        }
    }

    private func statCard(icon: String, color: Color, value: Int, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 22, weight: .semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .semibold))
                Text(text)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 12, weight: .medium))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.4))
              
              .clipShape(RoundedRectangle(cornerRadius: 40))
         
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }
}


// MARK: - Month & Year Wheel (بدون فاصل)
fileprivate struct MonthYearMergedWheel: View {
    @Binding var date: Date
    private let cal = Calendar.current

    @State private var selMonth = Calendar.current.component(.month, from: Date())
    @State private var selYear = Calendar.current.component(.year, from: Date())

    private var monthSymbols: [String] {
        let f = DateFormatter(); f.locale = .current
        return f.monthSymbols
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
            HStack(spacing: 0) {
                Picker("", selection: $selMonth) {
                    ForEach(1...12, id: \.self) { m in
                        Text(monthSymbols[m - 1]).tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(maxWidth: .infinity)

                Picker("", selection: $selYear) {
                    ForEach(selYear...(selYear + 10), id: \.self) { y in
                        Text(String(y)).tag(y)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(maxWidth: .infinity)
            }
            .mask(RoundedRectangle(cornerRadius: 16))
        }
        .onAppear {
            let comps = cal.dateComponents([.year, .month], from: date)
            selYear = comps.year ?? selYear
            selMonth = comps.month ?? selMonth
            commit()
        }
        .onChange(of: selMonth) { _ in commit() }
        .onChange(of: selYear) { _ in commit() }
    }

    private func commit() {
        var dc = DateComponents()
        dc.year = selYear
        dc.month = selMonth
        dc.day = 1
        if let new = cal.date(from: dc) {
            date = new
        }
    }
}
