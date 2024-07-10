import SwiftUI

struct ShoeRecommendationView: View {
    var body: some View {
        VStack {
            List {
                Section(header: Text("For experienced runners").font(.headline)) {
                    ShoeRecommendationHorizontalScroll(shoes: experiencedShoes)
                }
                
                Section(header: Text("For enthusiastic runners").font(.headline)) {
                    ShoeRecommendationHorizontalScroll(shoes: enthusiastShoes)
                }
                
                Section(header: Text("For Beginners runners").font(.headline)) {
                    ShoeRecommendationHorizontalScroll(shoes: beginnerShoes)
                }
            }
            .listStyle(GroupedListStyle())
        }
        .navigationTitle("What is the best Running Shoes for you?")
    }
}

struct ShoeRecommendationItem: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let imageName: String
}

struct ShoeRecommendationHorizontalScroll: View {
    var shoes: [ShoeRecommendationItem]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(shoes) { shoe in
                    VStack {
                        Image(shoe.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                            .padding(9)
                        Text(shoe.name)
                            .font(.custom("Avenir Next", size: 18))
                            .foregroundColor(.black)
                        Text(shoe.brand)
                            .font(.custom("Avenir Next", size: 18))
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 10)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

// Example data
let experiencedShoes = [
    ShoeRecommendationItem(name: "Adios Pro 3", brand: "Adidas", imageName: "adios"),
    ShoeRecommendationItem(name: "Metaspeed Sky", brand: "Asics", imageName: "asiscs1"),
    ShoeRecommendationItem(name: "Skyward X", brand: "Hoka", imageName: "hoka1"),
    ShoeRecommendationItem(name: "Wave Rebellion Pro 2", brand: "Mizuno", imageName: "mizuno1"),
    ShoeRecommendationItem(name: "Vapor Fly 3", brand: "Nike", imageName: "vapor"),
    ShoeRecommendationItem(name: "Nitro Elite 2", brand: "Puma", imageName: "nitro")
]

let enthusiastShoes = [
    ShoeRecommendationItem(name: "Boston 12", brand: "Adidas", imageName: "boston12"),
    ShoeRecommendationItem(name: "GEL Nimbus", brand: "Asics", imageName: "nimbus"),
    ShoeRecommendationItem(name: "Bondi 8", brand: "Hoka", imageName: "hoka2"),
    ShoeRecommendationItem(name: "Wave Rebellion Pro", brand: "Mizuno", imageName: "mizuno2"),
    ShoeRecommendationItem(name: "Zoom Fly 5", brand: "Nike", imageName: "zoomfly"),
    ShoeRecommendationItem(name: "Corre Supra", brand: "Olympikus", imageName: "corresupra"),
    ShoeRecommendationItem(name: "Forever Run", brand: "Puma", imageName: "nitro2")
]

let beginnerShoes = [
    ShoeRecommendationItem(name: "Duramo SL", brand: "Adidas", imageName: "duramo"),
    ShoeRecommendationItem(name: "GEL Pulse", brand: "Asics", imageName: "pulse"),
    ShoeRecommendationItem(name: "Pegasus", brand: "Nike", imageName: "pegasus"),
    ShoeRecommendationItem(name: "Corre 3", brand: "Olympikus", imageName: "corre3")
]

#if DEBUG
struct ShoeRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        ShoeRecommendationView()
    }
}
#endif
