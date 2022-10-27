//
//  ContentView.swift
//  CustomAuthDemo
//
//  Created by Shubham on 24/4/20.
//  Copyright © 2020 Shubham. All rights reserved.
//


import SwiftUI

struct ContentView: View {
    @ObservedObject var vm:ViewModel

    var body: some View {
        NavigationView {
            VStack {
                if vm.user != nil {
                    UserInfoView(vm: vm)
                } else {
                    LoginView(vm: vm)
                }
            }
            .alert(isPresented: $vm.showingAlert) {
                                    Alert(title: Text("Error"), message: Text("Login failed!"), dismissButton: .default(Text("OK")))
                                }
            .navigationBarTitle(Text("CustomAuth App"))
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vm: .init())
    }
}
