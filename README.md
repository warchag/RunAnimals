# 🏃‍♂️ RunAnimals - macOS Menu Bar CPU/RAM Monitor

RunAnimals is a fun and customizable macOS Menu Bar application that visualizes your system's current load (CPU or RAM usage) through animated animals and vehicles. The harder your Mac works, the faster they run!

## ✨ Features

- **Real-time Monitoring:** Choose between monitoring your CPU load or memory (RAM) usage.
- **Dynamic Speed Levels:** The animations react dynamically to system load with 5 distinct levels of speed and emojis (from Idle to Max Sprint).
- **Customizable Themes (15 options):** Pick your favorite characters to race across your menu bar:
  - 🐌 🐢 🐕 🐎 🐆 Classic
  - 😽 🐈 😼 🐅 🐆 Cat
  - 🛹 🚲 🛵 🚗 🚀 Vehicle
  - 🦕 🦎 🐊 🦖 🐉 Dinosaur
  - 🧊 🐧 🦭 🐬 🐋 Penguin
  - ...and 10 more fun themes!
- **Adjustable Track Length:** Choose how long the animation track is (Short, Medium, or Long).
- **Movement Direction Modes:**
  - ⬅️ ➡️ **Ping-Pong:** Bounce back and forth across the track.
  - ➡️ **Treadmill Right:** Continuous forward movement.
  - ⬅️ **Treadmill Left:** Continuous backward movement.
- **Dynamic Color Warnings:** The text color changes to alert you of high system loads:
  - Default: Below 60% load
  - 🟠 Orange: 60% - 79% load
  - 🔴 Red: 80%+ critical load
- **Launch at Login:** Option to start the app automatically when you boot your Mac.

## 🚀 Installation & Usage

### Running the App directly
1. Go to the `Releases` section on GitHub and download the `RunAnimals.app.zip`.
2. Extract the ZIP file.
3. Move `RunAnimals.app` to your `/Applications` folder.
4. Double-click to launch!

*(Note: On the first launch, macOS may warn you about an unidentified developer. Right-click the app, select "Open", and confirm to bypass this.)*

### Building from Source
RunAnimals is built entirely in Swift. No heavy dependencies or storyboards are required.
1. Clone this repository.
2. Open your terminal in the project directory.
3. Compile the `main.swift` source code using the Swift compiler:
   ```bash
   mkdir -p RunAnimals.app/Contents/MacOS
   swiftc main.swift -o RunAnimals.app/Contents/MacOS/RunAnimals
   ```
4. Copy the enclosed `Info.plist` file into the `RunAnimals.app/Contents/` directory to ensure it behaves as an `LSUIElement` (background menu bar app).

## 🎛 Settings 
Click the animal on your menu bar to open the options menu. All your preferences (Theme, Monitor target, Track length, Direction, and Login behavior) are saved automatically using `UserDefaults` and will persist across restarts.

## 🤝 Contributing
Feel free to fork this project, submit pull requests, or open an issue if you'd like to add more fun animal themes or new features!

--
*Built playfully for macOS.*
