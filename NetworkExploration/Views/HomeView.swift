//
//  HomeView.swift
//  NetworkExploration
//
//  Created by Reza Juliandri on 07/05/25.
//

import SwiftUI

struct WrapperAPIData: Codable{
    var data: [BasicData]
}
struct BasicData: Codable{
    var id: UUID
    var name: String
}

struct HomeView: View {
    class ViewModel: ObservableObject {
        var repository: Repository = Repository()
        
        @Published var datas: [BasicData] = []
        @Published var isLoading: Bool = false
        @Published var error: Error?
        
        func getData(){
            // Get all data
            repository.getData { result in
                switch(result){
                case .success(let data):
                    self.datas = data.data
                    print("Success")
                case .failure(let error):
                    self.error = error
                }
                
            }
        }
        
        func postData(){
            // Post random data
            let newData = BasicData(id: UUID(), name: "Test \(UUID().uuidString)")
            repository.postData(newData){ result in
                switch(result){
                case .failure(let error):
                    self.error = error
                case .success():
                    self.getData()
                }
            }
        }
        
        func putData(){
            // Get  last data
            guard var data = self.datas.last else {
                return
            }
            data.name = "Updated \(UUID().uuidString)"
            
            repository.putData(data) { result in
                switch(result){
                case .failure(let error):
                    self.error = error
                case .success():
                    self.getData()
                }
            }
        }
        
        func deleteData(){
            guard let lastId = self.datas.last?.id else {
                return
            }
            print("Last Id: \(lastId)")
            repository.deleteData(lastId) { result in
                switch(result){
                case .failure(let error):
                    self.error = error
                case .success():
                    self.getData()
                }
            }
        }
    }
    
    @ObservedObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        VStack {
            if((viewModel.error) != nil){
                Text("\(viewModel.error!)")
            }
            ButtonViewData(viewModel: viewModel)
            List {
                ForEach(viewModel.datas, id: \.id) { data in
                    VStack(alignment: .leading) {
                        Text("ID: \(data.id.uuidString.prefix(8).uppercased())")
                        Text("Name: \(data.name.prefix(8).uppercased())")
                    }
                    .padding(.vertical, 4) // Optional for spacing
                }
            }.onAppear() {
                viewModel.getData()
            }

        }
    }
}

struct ButtonViewData: View {
    var viewModel: HomeView.ViewModel
    var body: some View {
        VStack {
            Button {
                viewModel.getData()
            } label: {
                Text("GET Request")
                    .foregroundColor(Color.white)
            }
            .padding()
            .frame(width: 200)
            .background(Color.blue)
            .cornerRadius(20)
            Button {
                viewModel.postData()
            } label: {
                Text("POST Request")
                    .foregroundColor(Color.white)
            }
            .padding()
            .frame(width: 200)
            .background(Color.yellow)
            .cornerRadius(20)
            Button {
                viewModel.putData()
            } label: {
                Text("PUT Request")
                    .foregroundColor(Color.white)
                
            }
            .padding()
            .frame(width: 200)
            .background(Color.green)
            .cornerRadius(20)
            Button {
                viewModel.deleteData()
            } label: {
                Text("DELETE Request")
                    .foregroundColor(Color.white)
            }
            .padding()
            .frame(width: 200)
            .background(Color.red)
            .cornerRadius(20)
        }
    }
}

#Preview {
    HomeView()
}
