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
                    let encoded = try! JSONEncoder().encode(user.userInfo)
                    Text(String(data: encoded, encoding: .utf8)!)
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
