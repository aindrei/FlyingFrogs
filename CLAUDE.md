# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FlyingFrogs is an iOS SpriteKit-based 2D game built with Swift 5.0 and Xcode. The project uses a standard iOS MVC architecture with SpriteKit for game rendering.

## Build Commands

**Note:** All commands should be run from `/Users/alexi/projects/FlyingFrogs/FlyingFrogs` (the directory containing `FlyingFrogs.xcodeproj`).

### Building the Project

```bash
# Build for simulator
xcodebuild -project FlyingFrogs.xcodeproj -scheme FlyingFrogs -sdk iphonesimulator -configuration Debug build

# Build for device
xcodebuild -project FlyingFrogs.xcodeproj -scheme FlyingFrogs -sdk iphoneos -configuration Release build

# Clean build folder
xcodebuild -project FlyingFrogs.xcodeproj -scheme FlyingFrogs clean
```

### Running Tests

```bash
# Run all tests
xcodebuild test -project FlyingFrogs.xcodeproj -scheme FlyingFrogs -destination 'platform=iOS Simulator,name=iPhone 15'

# Run unit tests only
xcodebuild test -project FlyingFrogs.xcodeproj -scheme FlyingFrogs -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FlyingFrogsTests

# Run UI tests only
xcodebuild test -project FlyingFrogs.xcodeproj -scheme FlyingFrogs -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FlyingFrogsUITests

# Run a specific test
xcodebuild test -project FlyingFrogs.xcodeproj -scheme FlyingFrogs -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FlyingFrogsTests/FlyingFrogsTests/testExample
```

### Opening in Xcode

```bash
open FlyingFrogs.xcodeproj
```

## Architecture

### Project Structure

```
FlyingFrogs/
├── FlyingFrogs/              # Main application code
├── FlyingFrogsTests/         # Unit tests
├── FlyingFrogsUITests/       # UI/integration tests
└── FlyingFrogs.xcodeproj/    # Xcode project configuration
```

### Key Components

**AppDelegate.swift** (`FlyingFrogs/AppDelegate.swift`)
- Application entry point and lifecycle manager
- Handles app state transitions (background/foreground, active/inactive)
- Important: Games should pause in `applicationWillResignActive(_:)` and resume in `applicationDidBecomeActive(_:)`

**GameViewController.swift** (`FlyingFrogs/GameViewController.swift`)
- UIKit-SpriteKit bridge that loads and presents the game scene
- Loads scene from `GameScene.sks` file
- Configuration:
  - Scene scale mode: `.aspectFill`
  - Shows FPS and node count in debug (GameViewController.swift:29-30)
  - Status bar hidden
  - Supports all orientations except upside-down on iPhone

**GameScene.swift** (`FlyingFrogs/GameScene.swift`)
- Main game logic and scene management
- Inherits from `SKScene`
- Touch handling: Creates colored spinny nodes on touch (green=down, blue=move, red=up)
- Uses `SKAction` named "Pulse" from `Actions.sks` for label animation (GameScene.swift:66)
- Label node referenced as `//helloLabel` in scene hierarchy (GameScene.swift:19)
- `update(_:)` called before each frame for game loop logic

### SpriteKit Architecture

This project uses a **hybrid approach** combining visual scene editing with programmatic code:

1. **Scene Files (.sks)**
   - `GameScene.sks`: Visual scene layout edited in Xcode
   - `Actions.sks`: Reusable animations (contains "Pulse" action)
   - Loaded at runtime via `SKScene(fileNamed:)`

2. **Scene Code Pattern**
   - `didMove(to:)`: Initialize scene when loaded, find nodes by name from .sks file
   - `update(_:)`: Game loop called every frame
   - Touch handlers: `touchesBegan/Moved/Ended/Cancelled`
   - Delegate to helper methods: `touchDown/Moved/Up(atPoint:)`

3. **Node Queries**
   - Use `childNode(withName:)` to find nodes defined in .sks files
   - Use `//` prefix for deep search (e.g., `//helloLabel` searches entire hierarchy)

## Development Notes

### Scene Node Naming Convention
- Nodes in .sks files can be referenced by name in code
- Use `//nodeName` for recursive search through scene hierarchy (GameScene.swift:19)
- Cast to appropriate SKNode subclass (e.g., `as? SKLabelNode`)

### Touch Input Pattern
The project separates touch event handling into two layers:
1. Override `touches*` methods to iterate through touch set
2. Delegate to `touch*(atPoint:)` helper methods for actual logic
This separation allows easy customization of multi-touch vs single-touch behavior.

### Debug Visualization
FPS and node count are shown by default (GameViewController.swift:29-30). Disable in production builds or change `showsFPS`/`showsNodeCount` properties.

### Test Infrastructure
- Unit tests: `FlyingFrogsTests/FlyingFrogsTests.swift`
- UI tests: `FlyingFrogsUITests/FlyingFrogsUITests.swift`
- Launch tests: `FlyingFrogsUITests/FlyingFrogsUITestsLaunchTests.swift`
- Currently contain template code - implement as needed

## Targets and Build Configurations

- **FlyingFrogs**: Main application target
- **FlyingFrogsTests**: Unit test bundle (depends on FlyingFrogs)
- **FlyingFrogsUITests**: UI test bundle (depends on FlyingFrogs)

Build configurations: Debug, Release (default: Release)

## Dependencies

No external dependencies (Swift Package Manager, CocoaPods, or Carthage). The project uses only iOS SDK frameworks:
- UIKit
- SpriteKit
- GameplayKit
