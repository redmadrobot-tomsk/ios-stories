# Stories
[![Platform](https://img.shields.io/cocoapods/p/Stories.svg?style=flat)](https://github.com/redmadrobot-tomsk/ios-stories)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Stories.svg)](https://cocoapods.org/pods/Stories)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange)](https://swift.org/package-manager/)

Library for Instagram-like stories creating. 
You can create stories with different content: images, texts and buttons. With the help of ExampleApp you can explore Stories features.

## CocoaPods Install
Add `pod 'Stories'` to your Podfile.

## Carthage Install
```carthage
github "redmadrobot-tomsk/ios-stories" ~> 1.0.0
```

## Swift Package Manager Install
```swift
dependencies: [
    .package(url: "https://github.com/redmadrobot-tomsk/ios-stories", .upToNextMajor(from: "1.0.0"))
]
```

## Usage
`import Stories`

### Setting Up Stories View
Here we use default shared stories storage like data source for StoriesListView - StoriesStoringFactory.defaultStorage(). You can use your custom data source
```
class ViewController: UIViewController {
  private let listView = StoriesListView()
  private let storiesStorage = StoriesStoringFactory.defaultStorage()
  
  // Setup Stories List UI
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(listView)
    listView.presentingViewController = self
    listView.uiComponentsFactory = CustomComponentsFactory()
    // Setting stories list view layout
    // ...
    
    storiesStorage.configurator.setStoriesLifetime(.infinity).deleteExpiredStories(false)
      .orderBy(.date).orderDirection(.desc).show(.all).prefetchImages(true).reload()
  }
}
```

### Story Model
```
let story =
Story(id: "story_id", 
      title: "Story Title",
      imageURL: URL(string: "https://stories-api.com/story-image-url"),
      frames: [StoryFrame(content: StoryFrameContent(position: FrameContentPosition.top,
                                                     textColor: UIColor.black,
                                                     header1: "Header1",
                                                     header2: "Header2",
                                                     paragraphs: ["Paragraph1", "Paragraph2"],
                                                     action: FrameAction(text: "Action",
                                                                         urlString: "https://stories-api.com/story-action"),
                                                     controlsColorMode: FrameControlsColorMode.light,
                                                     gradient: StoryFrameGradient.both,
                                                     gradientColor: UIColor.red,
                                                     gradientStartAlpha: CGFloat = 0.7),
                          imageURL: URL(string: "https://stories-api.com/story-frame-url"),
                          isAlreadyShown: false)],
      isLiked: false,
      isSeen: false)
```
All models are Codable, so you can initialize them with ```init(from decoder: Decoder) throws```

### Updating Stories List with Models
```
try? storiesStorage.replace(with: [story])
```
If you use API, you can update stories with network response. For example:
```
struct StoriesResponse: Codable {
  let stories: [Story]
}
```

```
let session = URLSession.shared
guard let url = URL(string: "https://stories-api.com/stories") else { return }
session.dataTask(with: url) { [weak self] data, response, error in
  if let data = data {
    self?.handleResponse(data: data)
  }
}.resume()
  
private func handleResponse(data: Data) {
   do {
     let decoder = JSONDecoder()
     decoder.keyDecodingStrategy = .convertFromSnakeCase
     let response = try decoder.decode(StoriesResponse.self, from: data)
     DispatchQueue.main.async {
       try? self.storiesStorage.replace(with: response.stories)
     }
  } catch {
    print(error)
  }
}
```

## Requirements
- iOS 11.0+
- Swift 5.0+

# Contact
If you have any questions, please, contact us iosdev@rmr-t.ru

# License
Stories library is released under the MIT license. See LICENSE for details.
