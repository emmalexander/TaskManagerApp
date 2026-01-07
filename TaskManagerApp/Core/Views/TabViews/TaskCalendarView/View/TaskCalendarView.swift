import SwiftUI

struct TaskCalendarView: View {
    @ObservedObject var viewModel: TasksViewModel
    @State private var selectedIndex: Int = 1
    @State private var showingAddTask: Bool = false
    
    private let weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    private let dates = Array(3...9)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeaderView()
                
                MonthHeaderView {
                    showingAddTask = true
                }
                
                WeekdaySelectorView(
                    weekdays: weekdays,
                    dates: dates,
                    selectedIndex: $selectedIndex
                )
                
                Text("Tasks")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    ForEach(0..<3) { _ in
                        TaskCardView()
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
        }
        .sheet(isPresented: $showingAddTask) {
            NavigationStack { AddTaskView() }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
}

fileprivate struct HeaderView: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.purple.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.purple)
                )
            
            Spacer()
            
            Button {
                // search action placeholder
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct MonthHeaderView: View {
    var addTaskAction: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Text("Oct, 2020")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: addTaskAction) {
                Text("+ Add Task")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct WeekdaySelectorView: View {
    let weekdays: [String]
    let dates: [Int]
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(weekdays.indices, id: \.self) { i in
                let isSelected = i == selectedIndex
                VStack(spacing: 6) {
                    Text(weekdays[i])
                        .font(.system(size: 14).weight(.medium))
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 38, height: 46)
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 8, height: 8)
                                .offset(y: 16)
                            Text("\(dates[i])")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(height: 24)
                        } else {
                            Text("\(dates[i])")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(height: 24)
                        }
                    }
                }
                .frame(width: 38)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIndex = i
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct TaskCardView: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.purple.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.purple)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Design Changes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("2 Days ago")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    TaskCalendarView(viewModel: TasksViewModel())
}
