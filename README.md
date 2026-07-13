# Generative Ambient Music Engine 🌊✨

A native iOS application built using **SwiftUI** and **AVFoundation** that generates endless, evolving ambient soundscapes directly on the device. By eliminating static audio loops and heavy external audio assets, the entire application relies on real-time digital signal processing (DSP) and mathematical probability matrix distributions.

---

## 🧠 Core Architecture & Mathematical Design

The application translates sophisticated Web Audio structures into high-performance native Swift threads across a modular **MVVM Layout Architecture**:

* **Markov Chain / Random Walk:** The core melody generator rejects standard absolute randomness to prevent musical chaos. Instead, it computes a constrained mathematical random walk across specialized scale constraints (e.g., C Major Pentatonic, Hirajoshi Zen profiles), choosing adjacent harmonic steps using exponential distance weight biases.
* **Procedural Synthesis Graph:** Uses a native `AVAudioSourceNode` inside an isolated `AVAudioEngine` pipeline to generate raw wave structures and custom audio envelopes client-side.
* **Dynamic Feedback Space:** Feeds active instrumental layers into automated system delay loops (`AVAudioUnitDelay`) with up to 70% feedback parameters, transforming single note instances into rich, drifting accidental ambient harmonies.
* **60 FPS Responsive Visualization Canvas:** Employs SwiftUI's hardware-accelerated `Canvas` timeline pipeline to procedurally draw fluid low-frequency oscillator (LFO) wave movements and expanding visual pitch ripples matching active musical triggers instantly.

---

## 📂 Project Directory Roadmap

```text
📂 Core/
│   └── 📂 AudioEngine/         # AVAudioEngine nodes, synthesis loops & parameters
📂 Models/
│   └── Models.swift            # SoundscapeParams, MusicalScale, and SavedScene entities
📂 ViewModels/
│   └── AmbientViewModel.swift  # State machine, note timers, and Random Walk math logic
📂 Views/
│   ├── AppRootView.swift       # Master layout view container & theme routing maps
│   └── 📂 Components/
│       ├── WaveformVisualizerView.swift # Timeline render canvas particle ripple window
│       ├── SoundscapeMixerCard.swift    # Instrument matrix volume slider decks
│       └── PresetManagerView.swift      # Local storage persistent preset handlers
```
---

## 🛠️ Week 1 Milestone Achievements

[x] Implemented complete MVVM architectural module structure splitting interface layers from engine threads.

[x] Implemented custom Markov Chain Random Walk step calculator matrix.

[x] Configured native AVAudioEngine node graphs with active master output buses and structural delay wrappers.

[x] Rendered hardware-accelerated TimelineView Canvas visualizer converting live pitch properties to logarithmic coordinate nodes.

[x] Established persistent local data storage pipelines using UserDefaults JSON serialization.

---

## ⚙️ Requirements & Installation

- Development Environment: Xcode 15+ / Swift 5.9+

- Deployment Target: iOS 17.0+

- Dependencies: Fully standalone framework utilizing native Apple AVFoundation and SwiftUI architectures.

***Engine Developed client-side on the device audio threads. Fully optimized for endless meditation, deep focus, and creative relaxation.***
