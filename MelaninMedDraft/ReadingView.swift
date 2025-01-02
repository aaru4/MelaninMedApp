import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct ReadingView: View {
    @State private var showingSafari1 = false
    @State private var showingSafari2 = false
    @State private var showingSafari3 = false
    @State private var showingSafari4 = false
    @State private var showingSafari5 = false
    @State private var showingSafari6 = false
    @State private var showingSafari7 = false
    @State private var showingSafari8 = false
    @State private var showingSafari9 = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Daily Skin Care Tip")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
                    .multilineTextAlignment(.center)
                
                Text("Wear sunscreen every day.")
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .multilineTextAlignment(.center)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 4)
                    )
                    .padding(.horizontal, 10)
            }
            .padding()
            .padding(.bottom, 4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: colorPalette[2]))
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            
            VStack {
                Text("Melanin Rich Skincare")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            
            
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            
                            VStack {
                                
                                Button(action: {
                                    withAnimation {
                                        showingSafari1 = true
                                    }
                                }) {
                                    Image("audrey-m-jackson-cAFpd2vqnPE-unsplash")
                                        .resizable()
                                        .scaledToFit()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 300, height: 300)
                                        .clipped()
                                        .cornerRadius(15)
                                        .scaleEffect(1.0)
                                        .overlay(
                                            Text("Skin Care Secrets For Darker Skin")
                                                .font(.headline)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 15)
                                                .background(Color.black.opacity(0.40))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .padding(.bottom, 10)
                                                .frame(maxWidth: .infinity),
                                            alignment: .bottom
                                        )
                                }
                                .sheet(isPresented: $showingSafari1) {
                                    SafariView(url: URL(string: "https://www.aad.org/public/darker-skin/secrets")!)
                                }
                                
                                Text("American Academy of Dermatology")
                                    .font(.subheadline)
                            }
                            
                            VStack {
                                Button(action: {
                                    withAnimation {
                                        showingSafari2 = true
                                    }
                                }) {
                                    Image("ehteshamul-haque-adit-eF5B91VC4Ag-unsplash")
                                        .resizable()
                                        .scaledToFit()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 300, height: 300)
                                        .clipped()
                                        .cornerRadius(15)
                                        .scaleEffect(1.0)
                                        .overlay(
                                            Text("Do People of Color Need Sunscreen?")
                                                .font(.headline)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 15)
                                                .background(Color.black.opacity(0.40))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .padding(.bottom, 10)
                                                .frame(maxWidth: .infinity),
                                            alignment: .bottom
                                        )
                                }
                                .sheet(isPresented: $showingSafari2) {
                                    SafariView(url: URL(string: "https://healthtalk.unchealthcare.org/do-people-of-color-need-sunscreen/#:~:text=Everyone%2C%20including%20those%20with%20darker,wrinkles%2C%20sagging%20and%20age%20spots.")!)
                                }
                                
                                Text("University of North Carolina at Chapel Hill")
                                    .font(.subheadline)
                            }
                            
                            // Third Section
                            VStack {
                                Button(action: {
                                    withAnimation {
                                        showingSafari3 = true
                                    }
                                }) {
                                    Image("very-petty-girl-0n1JT8q6RJg-unsplash")
                                        .resizable()
                                        .scaledToFit()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 300, height: 300)
                                                                        .clipped()
                                        .cornerRadius(15)
                                        .scaleEffect(1.0)
                                        .overlay(
                                            Text("How to Care for Melanin Rich Skin")
                                                .font(.headline)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 15)
                                                .background(Color.black.opacity(0.40))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .padding(.bottom, 10)
                                                .frame(maxWidth: .infinity),
                                            alignment: .bottom
                                        )
                                }
                                .sheet(isPresented: $showingSafari3) {
                                    SafariView(url: URL(string: "https://blissoma.com/blog/how-to-care-for-melanin-rich-black-skin-tips/?srsltid=AfmBOoqRly90DQ3vbbuAQBSurLE4Tc8vFx1VecfX7Gv6WfmaPmApom62")!)
                                }
                                
                                Text("Blissoma")
                                    .font(.subheadline)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    }
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                
                // Second Horizontal ScrollView
                
                Text("Skin Cancer Basics")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
            
                        
                        VStack {
                            Button(action: {
                                withAnimation {
                                    showingSafari4 = true
                                }
                            }) {
                                Image("ghaly-wedinly-K07jvi25Qxg-unsplash")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 300)
                                                                    .clipped()
                                    .cornerRadius(15)
                                    .scaleEffect(1.0)
                                    .overlay(
                                        Text("Skin Cancer Basics")
                                            .font(.headline)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Color.black.opacity(0.40))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .padding(.bottom, 10)
                                            .frame(maxWidth: .infinity),
                                        alignment: .bottom
                                    )
                            }
                            .sheet(isPresented: $showingSafari4) {
                                SafariView(url: URL(string: "https://www.cdc.gov/skin-cancer/about/index.html")!)
                            }
                            
                            Text("Center for Disease Control")
                                
                                .font(.subheadline)
                        }
                        
                     
                        // Second Section
                        VStack {
                            Button(action: {
                                withAnimation {
                                    showingSafari5 = true
                                }
                            }) {
                                Image("jelique-edward-41wlAHSKY34-unsplash")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 300)
                                    .clipped()
                                    .cornerRadius(15)
                                    .scaleEffect(1.0)
                                    .overlay(
                                        Text("Skin Cancer")
                                            .font(.headline)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Color.black.opacity(0.40))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .padding(.bottom, 10)
                                            .frame(maxWidth: .infinity),
                                        alignment: .bottom
                                    )
                            }
                            .sheet(isPresented: $showingSafari5) {
                                SafariView(url: URL(string: "https://www.mayoclinic.org/diseases-conditions/skin-cancer/symptoms-causes/syc-20377605")!)
                            }
                            
                            Text("Mayo Clinic")
                                .font(.subheadline)
                        }
                        
                        VStack {
                            Button(action: {
                                withAnimation {
                                    showingSafari6 = true
                                }
                            }) {
                                Image("osarugue-igbinoba-pZbO3a1OgeA-unsplash")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 300)
                                    .clipped()
                                    .cornerRadius(15)
                                    .scaleEffect(1.0)
                                    .overlay(
                                        Text("Effects of Skin Cancer Treatment")
                                            .font(.headline)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Color.black.opacity(0.40))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .padding(.bottom, 10)
                                            .frame(maxWidth: .infinity),
                                        alignment: .bottom
                                    )
                            }
                            .sheet(isPresented: $showingSafari6) {
                                SafariView(url: URL(string: "https://siteman.wustl.edu/treatment/cancer-types/skin/effects-of-treatment/")!)
                            }
                            
                            Text("Siteman Cancer Center")
                                .font(.subheadline)
                        }
                        
                      
                        
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
                .padding(.bottom, 20)
                .padding(.leading, 20)
                
                // Third
                
                Text("Prevention")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        

                        // First Section
                        VStack {
                            Button(action: {
                                withAnimation {
                                    showingSafari7 = true
                                }
                            }) {
                                
                                
                                Image("alvin-balemesa-MYfq3tf34p8-unsplash")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 300)
                                    .clipped()
                                    .cornerRadius(15)
                                    .scaleEffect(1.0)
                                    .overlay(
                                        Text("Skin Cancer Prevention")
                                            .font(.headline)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Color.black.opacity(0.40))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .padding(.bottom, 10)
                                            .frame(maxWidth: .infinity),
                                        alignment: .bottom
                                    )
                            }
                            .sheet(isPresented: $showingSafari7) {
                                SafariView(url: URL(string: "https://www.skincancer.org/skin-cancer-prevention/")!)
                            }
                            
                            Text("The Skin Cancer Foundation")
                                .font(.subheadline)
                        }
                        // Second Section
                        VStack {
                            Button(action: {
                                withAnimation {
                                    showingSafari8 = true
                                }
                            }) {
                                Image("natallia-photo-KRfx2mXnQn8-unsplash")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 300)
                                    .clipped()
                                    .cornerRadius(15)
                                    .scaleEffect(1.0)
                                    .overlay(
                                        Text("Reducing Risk for Skin Cancer")
                                            .font(.headline)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Color.black.opacity(0.40))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .padding(.bottom, 10)
                                            .frame(maxWidth: .infinity),
                                        alignment: .bottom
                                    )
                            }
                            .sheet(isPresented: $showingSafari8) {
                                SafariView(url: URL(string: "https://www.cdc.gov/skin-cancer/prevention/index.html")!)
                            }
                            
                            Text("Center for Disease Control")
                                .font(.subheadline)
                        }
                        
                        // Third Section
                        VStack {
                            Button(action: {
                                withAnimation {
                                    showingSafari9 = true
                                }
                            }) {
                            
                            
                                Image("angelica-echeverry-5KY5LP_zc44-unsplash")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 300, height: 300)
                                    .clipped()
                                    .cornerRadius(15)
                                    .scaleEffect(1.0)
                                    .overlay(
                                        Text("Early Detection: Spot the Cancer When It's Easiest to Treat")
                                            .font(.headline)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(Color.black.opacity(0.40))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .padding(.bottom, 10)
                                            .frame(maxWidth: .infinity),
                                        alignment: .bottom
                                    )
                            }
                            .sheet(isPresented: $showingSafari9) {
                                SafariView(url: URL(string: "https://www.skincancer.org/early-detection/#:~:text=That's%20why%20skin%20exams%2C%20both,become%20dangerous%2C%20disfiguring%20or%20deadly.")!)
                            }
                            
                            Text("The Skin Cancer Foundation")
                                .font(.subheadline)
                        }
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
                .padding(.bottom, 20)
                .padding(.leading, 20)
          
            
          
            }
        }
    }
    
    struct ReadingView_Previews: PreviewProvider {
        static var previews: some View {
            ReadingView()
        }
    }
}
