# Weather Brick
Application that works with the location and weather API

The Weather Forecast Brick App is designed to provide users with a unique and playful way of checking the weather. It displays a weather brick on a rope, and the appearance of the brick changes based on the current weather conditions at the user's location.

## Requirements

- iOS 12 and above
- Portrait mode only
- iPhone device only
- Internet connectivity for weather data updates

## Stack

- Swift
- UIKit
- Auto Layout for responsive design
- Storyboard for UI design
- URLSession for network requests
- Codable for JSON parsing
- Gesture Recognizers for user interactions
- Model-View-Controller (MVC) architectural pattern
- Third-party weather API for weather data
- Design tools: Figma for UI/UX design

## Functionality

- The app determines the user's current location and displays the weather using a creative "weather brick on a rope" visual metaphor.

- The weather brick's appearance changes based on the current weather conditions:
  - If it's raining, the brick appears wet.
  - If it's sunny, the brick is dry.
  - In foggy conditions, the brick becomes hard to see.
  - Extreme heat causes cracks to appear on the brick's surface.
  - During snowfall, the brick gets covered with snow.
  - Strong winds make the brick sway on the rope.
  - If there's no internet connection, the brick disappears until data is available.

- The app implements a pull-to-refresh behavior: When the user pulls the rope down, there is a visual response, indicating the app is updating the weather data.

## Installation and Usage

1. Clone this repository to your local machine.

2. Open the Xcode project file.

3. Configure your Xcode environment and build settings.

4. Run the app on the iOS Simulator or a physical iPhone device.

5. Ensure you have an internet connection to fetch the latest weather data.

## API

The app utilizes free public weather APIs to retrieve weather data. For example, [OpenWeatherMap API](https://openweathermap.org/api) is a suitable option.

## Design

The app's design is inspired by the Figma template available at the following link: [Weather Forecast Design]

## Credits

- Weather data is retrieved from third-party weather APIs, such as OpenWeatherMap.

- Design inspiration is from the Figma template mentioned above.

- For a guide on making API calls in Swift, you can refer to this [useful tutorial](https://www.swiftwithvincent.com/blog/how-to-write-your-first-api-call-in-swift).

## License

This project is distributed under the [MIT License](LICENSE).

---

For further assistance or inquiries, please refer to the project documentation or contact the project maintainers.
