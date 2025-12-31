# Flying Frogs - Development Plan

A Flappy Bird-style game where a frog flies through obstacles by tapping to flap.

## Game Concept

- **Player**: A frog that falls due to gravity and flaps upward on tap
- **Obstacles**: Pairs of lily pads/logs with gaps to fly through
- **Goal**: Fly as far as possible without hitting obstacles or ground/ceiling
- **Scoring**: +1 point for each obstacle passed

---

## Phase 1: Core Physics & Player Control

**Goal**: Get a frog on screen that responds to tap input with proper gravity.

### Tasks
- [x] Create `FrogSprite` class (SKSpriteNode subclass)
- [x] Add frog placeholder sprite (colored rectangle or simple shape)
- [x] Implement gravity (constant downward velocity)
- [x] Implement flap mechanic (upward impulse on tap)
- [x] Add rotation based on velocity (nose up when rising, nose down when falling)
- [x] Set up ground collision boundary
- [x] Set up ceiling collision boundary

### Deliverable
Tappable frog that flaps upward and falls with gravity. Stops at ground/ceiling.

---

## Phase 2: Scrolling World & Obstacles

**Goal**: Add scrolling obstacles the frog must navigate through.

### Tasks
- [x] Create `ObstaclePair` class for top/bottom obstacle pair with gap
- [x] Implement obstacle spawning at regular intervals
- [x] Add horizontal scrolling (obstacles move left)
- [x] Remove obstacles when they exit screen left
- [x] Randomize gap vertical position within safe bounds
- [x] Add scrolling ground/background for movement feel

### Deliverable
Obstacles scroll from right to left with randomized gaps. World feels like it's moving.

---

## Phase 3: Collision Detection & Game Over

**Goal**: Detect collisions and implement game over state.

### Tasks
- [ ] Set up physics categories (frog, obstacle, ground, gap/score zone)
- [ ] Implement `SKPhysicsContactDelegate`
- [ ] Detect frog-obstacle collision → trigger game over
- [ ] Detect frog-ground collision → trigger game over
- [ ] Create game over state (stop scrolling, stop spawning)
- [ ] Display "Game Over" label
- [ ] Add tap to restart functionality

### Deliverable
Game ends on collision. Player can restart by tapping.

---

## Phase 4: Scoring System

**Goal**: Track and display score.

### Tasks
- [x] Add invisible score zone in gap between obstacles
- [x] Detect when frog passes through score zone
- [x] Increment score counter
- [x] Display score label (top center of screen)
- [x] Show final score on game over
- [x] Track and display high score (persist with UserDefaults)

### Deliverable
Score increments when passing obstacles. High score persists between sessions.

---

## Phase 5: Game States & Menu (Deferred/Optional)

**Goal**: Proper game flow with start menu.

### Tasks
- [ ] Create game state enum: `.ready`, `.playing`, `.gameOver`
- [ ] Implement ready state (frog bobs, "Tap to Start" prompt)
- [ ] Transition to playing state on first tap
- [ ] Implement game over state with restart option
- [ ] Add title label for ready state
- [ ] Optional: Add simple main menu scene

### Deliverable
Complete game flow from title → gameplay → game over → restart.

---

## Phase 6.1: Sprites

**Goal**: Replace placeholders with actual frog graphics.

### Tasks
- [x] Create/obtain frog sprite (or sprite sheet)
- [x] Create obstacle sprites (lily pads, logs, or pipes)

### Deliverable
Game looks polished with proper art assets and animations.

## Phase 6.2: Background

**Goal**: Create a proper scrolling background.

### Tasks
- [ ] Add parallax scrolling background layers
- [ ] Create ground texture that tiles seamlessly

### Deliverable
Game looks polished with proper art assets and animations.
---

## Phase 6.3: Visual Feedback

**Goal**: Make visuals more polished. 

### Tasks
- [ ] Add visual feedback on score (brief flash or scale)

### Deliverable
Game looks polished with proper art assets and animations.
---



## Phase 7: Audio & Polish

**Goal**: Add sound effects and final polish.

### Tasks
- [ ] Add flap sound effect
- [ ] Add score sound effect
- [ ] Add collision/game over sound effect
- [ ] Add background music (optional, looping)
- [ ] Add screen shake on collision
- [ ] Add particle effects (splash on water, feathers on hit)
- [ ] Implement difficulty progression (speed increase over time)

### Deliverable
Game feels complete with audio feedback and juice.

---

## Phase 8: Final Polish & Release Prep

**Goal**: Prepare for release.

### Tasks
- [ ] Create app icon
- [ ] Create launch screen
- [ ] Test on multiple device sizes
- [ ] Optimize performance (node count, texture atlases)
- [ ] Add Game Center leaderboard (optional)
- [ ] Remove debug overlays (FPS, node count)
- [ ] Test and fix edge cases

### Deliverable
Release-ready game.

---

## Technical Notes

### Physics Setup
```
Category Bitmasks:
- frog:     0x1 << 0 (1)
- obstacle: 0x1 << 1 (2)
- ground:   0x1 << 2 (4)
- scoreZone: 0x1 << 3 (8)

Contact Tests:
- frog contacts obstacle, ground → game over
- frog contacts scoreZone → increment score
```

### Key Constants (tune during development)
- Gravity: -9.8 to -15 (experiment)
- Flap impulse: 300-500 (adjust for feel)
- Scroll speed: 150-200 points/sec
- Obstacle spawn interval: 1.5-2.5 seconds
- Gap size: 150-200 points (adjust for difficulty)

### File Structure
```
FlyingFrogs/
├── Sprites/
│   ├── FrogSprite.swift
│   └── ObstaclePair.swift
├── Scenes/
│   ├── GameScene.swift (main gameplay)
│   └── MenuScene.swift (optional)
├── Managers/
│   ├── GameManager.swift (state, score)
│   └── AudioManager.swift (sounds)
└── Extensions/
    └── SKNode+Extensions.swift (helpers)
```

---

## Progress Tracking

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Core Physics | ✅ Complete | FrogSprite, gravity, flap, rotation, boundaries |
| 2. Scrolling World | ✅ Complete | ObstaclePair, spawning, scrolling ground |
| 3. Collision & Game Over | ✅ Complete | Already implemented in Phase 1 & 2 |
| 4. Scoring | ✅ Complete | Score display, high score with UserDefaults |
| 5. Game States | Not Started | |
| 6. Visual Assets | Not Started | |
| 7. Audio & Polish | Not Started | |
| 8. Release Prep | Not Started | |
