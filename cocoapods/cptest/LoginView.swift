import SwiftUI

struct LoginView: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        List {
            Section(header: Text("Single Logins")) {
                Group {
                    Button(action: {
                        vm.googleLogin()
                    }, label: {
                        Text("Google Login")
                    })
                }

                Button(action: {
                    vm.discordLogin()
                }, label: {
                    Text("Discord Login")
                })

                Button(action: {
                    vm.facebookLogin()
                }, label: {
                    Text("Facebook Login")
                })

                Button(action: {
                    vm.twitchLogin()
                }, label: {
                    Text("Twitch Login")
                })

                Button(action: {
                    vm.githubLogin()
                }, label: {
                    Text("Github Login")
                })

                Button(action: {
                    vm.appleLogin()
                }, label: {
                    Text("Apple Login")
                })

                Button(action: {
                    vm.emailPasswordLogin()
                }, label: {
                    Text("Email-Password Login")
                })
            }
        }
        .foregroundColor(.black)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(vm: .init())
    }
}
