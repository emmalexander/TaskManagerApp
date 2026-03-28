//
//  ProfileView.swift
//  TaskManagerApp
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    header
                    
                    // Profile Info
                    profileHeader
                    
                    // Statistics
                    statsSection
                    
                    // Menu Items
                    menuSection
                    
                    // Logout Button
                    logoutButton
                }
                .padding(.bottom, 100)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $viewModel.logUserOut){
                SignInView()
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("Profile")
                .font(.largeTitle.weight(.bold))
            Spacer()
//            Button(action: {}) {
//                Image(systemName: "gearshape.fill")
//                    .font(.title3)
//                    .foregroundStyle(.secondary)
//                    .padding(10)
//                    .background(Circle().fill(Color(uiColor: .secondarySystemBackground)))
//            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: 0x7B61FF), Color(hex: 0x5B8BFF)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                
                Text(String(mainTabViewModel.user?.firstName.first ?? "U"))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color(hex: 0x7B61FF).opacity(0.3), radius: 15, x: 0, y: 10)
            
            VStack(spacing: 4) {
                Text("\(mainTabViewModel.user?.firstName ?? "Loading") \(mainTabViewModel.user?.lastName ?? "...")")
                    .font(.title2.weight(.bold))
                
                Text(mainTabViewModel.user?.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            StatCard(title: "Completed", value: "\(viewModel.completedTasksNumber)", icon: "checkmark.circle.fill", color: Color(hex: 0x7B61FF))
            StatCard(title: "Pending", value: "\(viewModel.pendingTasksNumber)", icon: "clock.fill", color: Color(hex: 0x5B8BFF))
        }
        .padding(.horizontal, 20)
    }
    
    private var menuSection: some View {
        VStack(spacing: 0) {
            Button(action: { viewModel.showingPersonalInfo = true }) {
                MenuRow(icon: "person.fill", title: "Personal Info", color: .blue)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $viewModel.showingPersonalInfo) {
                PersonalInfoView()
            }
            
            Divider().padding(.leading, 56)
            
            NavigationLink(destination: ManageTaskListsView()) {
                MenuRow(icon: "list.bullet.rectangle.fill", title: "Manage Task Lists", color: .purple)
            }
            .buttonStyle(.plain)
            
            Divider().padding(.leading, 56)
            MenuRow(icon: "bell.fill", title: "Notifications", color: .red)
            Divider().padding(.leading, 56)
            MenuRow(icon: "shield.fill", title: "Security", color: .green)
            Divider().padding(.leading, 56)
            MenuRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .orange)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemBackground)))
        .padding(.horizontal, 20)
    }
    
    private var logoutButton: some View {
        Button(action: {
            viewModel.logout()
            //Navigate to login
            mainTabViewModel.selectedTab = 0
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Log Out")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 20)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .padding(10)
                .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.weight(.bold))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemBackground)))
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(color, in: RoundedRectangle(cornerRadius: 10))
            
            Text(title)
                .font(.subheadline.weight(.medium))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
    }
}

#Preview {
    ProfileView()
        .environmentObject(MainTabViewModel())
}
