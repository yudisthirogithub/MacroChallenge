//
//  ContentView.swift
//  testingCallFile
//
//  Created by Yudis Huang on 05/10/20.
//  Copyright © 2020 Yudis Huang. All rights reserved.
//

import SwiftUI

struct EmergencyView: View {
    @EnvironmentObject var navPop : NavigationPopObject

    @FetchRequest(fetchRequest: Emergency.getAllEmergency()) var contacts: FetchedResults<Emergency>
    @Environment(\.managedObjectContext) var manageObjectContext
    @State var isAlert : Bool = false
    

    @State var isAddNewContact: Bool = false
    @State var contactEdited: Bool = false
    
    @State var isEdited: Bool = false

    @State var id: UUID = UUID()
    @State var name: String = ""
    @State var number: String = ""

    let sendWatchHelper = WatchHelper()

    @State var contact2DArray = [[String]]()
    
    var body: some View {
        ZStack {
            VStack{
                HStack {
                    Text("Top Contacts")
                        .font(.title)
                        .padding()
                    Spacer()
                    Button(action: {
                        isEdited.toggle()
                    }, label: {
                        if isEdited{
                            Text("Done")
                                .padding()
                                .background(SomeBackground.editBackground())
                        }else{
                            Text("Edit")
                                .padding()
                                .background(SomeBackground.editBackground())
                        }

                    })
                    if !isEdited {
                        ZStack {
                            SomeBackground.plusBackground()
                            Button(action: {
                                self.isAddNewContact = true
                                navPop.tabIsHidden = true
                            }, label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                            })

                        }
                    }
                }.animation(.easeInOut(duration: 0.6))
                .frame(width : ScreenSize.windowWidth() * 0.9)
                Button {
                    sync()
                } label: {
                    Text("Sync With Apple Watch")
                }

                ForEach(self.contacts){ contact in
                    Button(action: {
                        if isEdited{
                            navPop.emergency = true
                            navPop.tabIsHidden = true
                            
                            self.id = contact.id
                            self.name = contact.name!
                            self.number = contact.number!
                            
                            
                            //pake ini biar textfieldnya udh ada isinya waktu modal dipanggil
                            //entah knp harus diginiin baru bisa
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.contactEdited = true
                            }
                        }else{
                            call(number: contact.number!)
                        }

                    }, label: {
                        HStack {
                            if isEdited{
                                Button(action: {
                                    isAlert = true
                                }, label: {
                                    Image(systemName: "x.circle")
                                        .padding()
                                })
                                .alert(isPresented: $isAlert){
                                    Alert(title: Text("Delete"), message: Text("Yakin mau dihapus? :)"), primaryButton: .destructive(Text("Delete")) {
                                        self.manageObjectContext.delete(contact)

                                        do {
                                            try self.manageObjectContext.save()
                                        } catch {
                                            print("error deleting")
                                        }
                                        }, secondaryButton: .cancel())
                                }
                            }
                            VStack {
                                Text("\(contact.name!)")
                                Text("\(contact.number!)")
                            }
                            Spacer()
                            if !isEdited{
                                Button(action: {
                                    call(number: contact.number!)
                                }, label: {
                                    Image(systemName: "phone.fill")
                                })
                            }

                        }
                        .animation(.easeInOut(duration: 0.6))
                        .padding()
                        .frame(width: ScreenSize.windowWidth() * 0.9, height: ScreenSize.windowHeight() * 0.1)
                        .background(Rectangle()
                                        .fill(Color.clear)
                                        .background(Blur(style: .systemThinMaterial)
                                                        .opacity(0.95))
                                        .cornerRadius(8))
                    })
                }
                .padding(.bottom, 8)
                Spacer()
            }
            .background(Image("ocean").backgroundImageModifier())

            HalfModalView(isShown: $isAddNewContact) {
                AddEmergencyContact(isAddNewContact: $isAddNewContact)
            }

            HalfModalView(isShown: $contactEdited) {
                EditEmergencyContact(name: self.$name, number: self.$number, id: self.id, contactEdited: self.$contactEdited)
            }
        }
    }
}

extension EmergencyView{
    func call(number : String){
        guard let phoneNumber =  number as String?, let url = URL(string:"telprompt://\(phoneNumber)") else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func sync() {
        for contact in self.contacts {
            var contactArray = [String]()
            contactArray.append(contact.id.uuidString)
            contactArray.append(contact.name!)
            contactArray.append(contact.number!)
            contact2DArray.append(contactArray)
        }
        sendWatchHelper.sendArrayOfContact(contact: contact2DArray)
    }
    
    func deleteItem(indexSet: IndexSet) {
        let deleteItem = self.contacts[indexSet.first!]
        self.manageObjectContext.delete(deleteItem)
        
        do {
            try self.manageObjectContext.save()
        } catch {
            print("error deleting")
        }
    }
}

struct EmergencyView_Previews: PreviewProvider {

    static var previews: some View {
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        EmergencyView().environmentObject(NavigationPopObject()).environment(\.managedObjectContext, viewContext)

    }
}
