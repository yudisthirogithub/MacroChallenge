//
//  AfterBreathingView.swift
//  MacroChallenge
//
//  Created by Kenji Surya Utama on 13/10/20.
//

import SwiftUI

struct AfterBreathingView: View {
    
    @EnvironmentObject var navPop : NavigationPopObject
    
    var body: some View {
        VStack {
            Button(action: {
                navPop.toBreathing = false
            }, label: {
                Text("Repeat")
            }).padding()
            
            Button(action: {
                navPop.toHome = false
            }, label: {
                Text("Go Home")
            }).padding()
            
            NavigationLink(
                destination: EmergencyView(),
                label: {
                    Text("Emergency")
                }).padding()
            
                
        }
        .navigationBarHidden(true)
    }
}

struct AfterBreathingView_Previews: PreviewProvider {
    static var previews: some View {
        AfterBreathingView().environmentObject(NavigationPopObject())
    }
}