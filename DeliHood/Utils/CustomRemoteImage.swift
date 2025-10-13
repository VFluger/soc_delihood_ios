import SwiftUI
import SDWebImageSwiftUI
import SDWebImageAVIFCoder

struct CustomRemoteImage: View {
    var UrlString: String?
    
    let placeholderView: () -> AnyView
    let isCaching: Bool
    
    init(urlString: String? = nil, @ViewBuilder placeholderView: @escaping () -> some View, isCaching: Bool = true) {
        self.UrlString = urlString
        self.placeholderView = { AnyView(placeholderView())}
        self.isCaching = isCaching
        
        // Register AVIF coder once
        let AVIFCoder = SDImageAVIFCoder.shared
        SDImageCodersManager.shared.addCoder(AVIFCoder)
    }
    
    var body: some View {
        if let url = URL(string: UrlString ?? "") {
            WebImage(
                url: url,
                context: [
                    .downloadRequestModifier: SDWebImageDownloaderRequestModifier { request in
                        var r = request
                        r.setValue("Bearer \(AuthManager.shared.getAccessToken() ?? "")", forHTTPHeaderField: "Authorization")
                        return r
                    }
                ]
            ) { image in
                image.resizable()
            } placeholder: {
                placeholderView()
            }
        } else {
            placeholderView()
        }
    }
}

#Preview {
    CustomRemoteImage(urlString: "https://your-server/image.avif") {
        Image("food-placeholder")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.primary)
            .frame(width: 50)
    }
}
