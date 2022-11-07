//
//  UserInfoView.swift
//  cptest
//
//  Created by Dhruv Jaiswal on 27/10/22.
//  Copyright © 2022 torus. All rights reserved.
//

import SwiftUI

struct UserInfoView: View {
    @ObservedObject var vm: ViewModel

    var body: some View {
        if let user = vm.user {
            List {
                Section {
                    Text("\(user.privateKey)")
                } header: {
                    Text("Private key")
                }
                Section {
                    Text("\(user.publicAddress)")
                }
            header: {
                    Text("Public Address")
                }
                Section {
                    ForEach(user.userInfo.sorted(by: >), id: \.key) { key, value in

                        Text("\(key): \(value)")
                    }
                }
            header: {
                    Text("User Info")
                }
            }
            .listStyle(.automatic)
            .navigationBarItems(trailing: Button {
                vm.removeUser()
            }
        label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.black)
            })
        }
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoView(vm: ViewModel())
    }
}
