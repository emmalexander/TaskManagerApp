//
//  TaskTabView.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import SwiftUI

struct TaskTabView: View {
    @ObservedObject var viewModel: TasksViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                        .padding(.horizontal, 20)
                    greeting
                        .padding(.horizontal, 20)
                    segmentControl
                        .padding(.horizontal, 20)
                    projectCarousel
                    progressSection
                        .padding(.horizontal, 20)
                }
                //
                .padding(.top, 12)
                .padding(.bottom, 100) // space for bottom bar
            }

        }
        .background(Color(uiColor: .systemGroupedBackground))
        
    }
}

// MARK: - Header
private extension TaskTabView {
    var header: some View {
        HStack {
            Text("Home")
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .imageScale(.medium)
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .imageScale(.medium)
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
    }

    var greeting: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hello Rohan!")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
            Text("Have a nice day.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Segment Control
private extension TaskTabView {
    var segmentControl: some View {
        HStack(spacing: 8) {
            segmentButton(title: "My Tasks", index: 0)
            segmentButton(title: "In-progress", index: 1)
            segmentButton(title: "Completed", index: 2)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    func segmentButton(title: String, index: Int) -> some View {
        Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { viewModel.selectedSegment = index } }) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(viewModel.selectedSegment == index ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if viewModel.selectedSegment == index {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(LinearGradient(colors: [Color(hex: 0x7B61FF), Color(hex: 0x5B8BFF)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.clear)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Project Carousel
private extension TaskTabView {
    var projectCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ProjectCardView(title: "Front-End\nDevelopment", subtitle: "Project 1", date: "October 20, 2020", gradient: [Color(hex: 0x7B61FF), Color(hex: 0xA37BFF)])
                    ProjectCardView(title: "Back-End\nDevelopment", subtitle: "Project 2", date: "October 24, 2020", gradient: [Color(hex: 0x5B8BFF), Color(hex: 0x7B61FF)])
                    ProjectCardView(title: "UI/UX\nDesign", subtitle: "Project 3", date: "November 02, 2020", gradient: [Color(hex: 0xFF7AC8), Color(hex: 0x7B61FF)])
                }
                .padding(.trailing, 20)
                .padding(.horizontal, 20)
            }
        }
    }
}

struct ProjectCardView: View {
    let title: String
    let subtitle: String
    let date: String
    let gradient: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(8)
                        .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(8)
                        .background(.white.opacity(0.15), in: Circle())
                }
                .buttonStyle(.plain)
            }

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(date)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(16)
        .frame(width: 240, alignment: .leading)
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.08))
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 10)
    }
}

// MARK: - Progress Section
private extension TaskTabView {
    var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(spacing: 12) {
                ForEach(0..<2) { _ in
                    ProgressRowView(title: "Design Changes", subtitle: "2 Days ago")
                }
            }
        }
        .padding(.top, 8)
    }
}

struct ProgressRowView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: 0xFFF0F5))
                    .frame(width: 44, height: 44)
                Image(systemName: "paintbrush.fill")
                    .foregroundStyle(Color(hex: 0xFF6AA2))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(uiColor: .quaternaryLabel).opacity(0.2))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}



#Preview {
    NavigationStack {
        TaskTabView(viewModel: TasksViewModel())
            .navigationTitle("")
            .navigationBarHidden(true)
    }
}
