//
//  TaskCalendarView.swift
//  TaskManagerApp
//

import SwiftUI

struct TaskCalendarView: View {
    @StateObject var viewModel = TaskCalendarViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Date Picker Placeholder (Simple horizontal week view)
                    weekCalendar
                    
                    // Tasks Section
                    tasksSection
                }
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Calendar")
                    .font(.largeTitle.weight(.bold))
                Text(Date().formatted(.dateTime.month(.wide).year()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(10)
                    .background(Circle().fill(Color(uiColor: .secondarySystemBackground)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var weekCalendar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<14) { index in
                    let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                    
                    Button(action: { withAnimation { viewModel.selectedDate = date } }) {
                        VStack(spacing: 12) {
                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(isSelected ? .white : .secondary)
                            
                            Text(date.formatted(.dateTime.day()))
                                .font(.headline.weight(.bold))
                                .foregroundStyle(isSelected ? .white : .primary)
                        }
                        .frame(width: 50, height: 80)
                        .background(
                            Group {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(LinearGradient(colors: [Color(hex: 0x7B61FF), Color(hex: 0x5B8BFF)], startPoint: .top, endPoint: .bottom))
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                }
                            }
                        )
                        .shadow(color: isSelected ? Color(hex: 0x7B61FF).opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Schedule")
                .font(.headline)
                .padding(.horizontal, 20)
            
            if viewModel.tasksForSelectedDate.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("No tasks for this day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // In a real app, we would list tasks here
                ForEach(viewModel.tasksForSelectedDate) { task in
                    TaskRow(task: task)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct TaskRow: View {
    let task: TaskModel
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: 0x7B61FF))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                Text(task.status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("10:00 AM") // Placeholder
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(uiColor: .secondarySystemBackground)))
    }
}

#Preview {
    TaskCalendarView()
        .environmentObject(MainTabViewModel())
}
