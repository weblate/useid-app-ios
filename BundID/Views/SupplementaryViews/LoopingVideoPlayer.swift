import SwiftUI
import AVKit

struct LoopingPlayer: UIViewRepresentable {
    
    let fileURL: URL
    @Binding var syncedTime: CMTime
    
    let shortTime = CMTime(seconds: 0.01, preferredTimescale: 6000)
    
    func makeUIView(context: Context) -> CustomVideoPlayer {
        let playerItem = AVPlayerItem(url: fileURL)
        let player = AVPlayer(playerItem: playerItem)
        
        context.coordinator.player = player
        
        let view = CustomVideoPlayer(player: player)
        
        player.seek(to: syncedTime, toleranceBefore: shortTime, toleranceAfter: shortTime) { _ in
            player.play()
        }
        
        context.coordinator.timeObserverToken = player.addPeriodicTimeObserver(forInterval: shortTime,
                                                                               queue: .main) { time in
            syncedTime = time
        }
        
        context.coordinator.observerToken = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                                   object: player.currentItem,
                                                                                   queue: nil) { [weak player] _ in
            player?.seek(to: CMTime.zero)
            player?.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: CustomVideoPlayer, context: Context) { }
    
    static func dismantleUIView(_ uiView: CustomVideoPlayer, coordinator: Coordinator) {
        coordinator.observerToken.flatMap { NotificationCenter.default.removeObserver($0) }
        coordinator.observerToken = nil
        coordinator.timeObserverToken.flatMap { coordinator.player?.removeTimeObserver($0) }
        coordinator.timeObserverToken = nil
        coordinator.player = nil
    }
    
    typealias UIViewType = CustomVideoPlayer
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        var observerToken: NSObjectProtocol?
        var timeObserverToken: Any?
    }
}

class CustomVideoPlayer: UIView {
    
    private var playerLayer = AVPlayerLayer()
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        playerLayer.contentsGravity = .resizeAspect
        
        layer.addSublayer(playerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        playerLayer.removeAllAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LoopingPlayer_Previews: PreviewProvider {
    static var previews: some View {
        LoopingPlayer(fileURL: Bundle.main.url(forResource: "scanAnimation",
                                               withExtension: "mp4")!,
                      syncedTime: .constant(CMTime(seconds: 2.0, preferredTimescale: 1000)))
    }
}