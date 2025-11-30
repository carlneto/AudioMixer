# 📦 Audio Mixer App

### Intelligent Voice-Aware Audio Mixing for macOS

[![Platform](https://img.shields.io/badge/platform-macOS_14+-lightgrey.svg)]()
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-15.0-blue.svg)]()
[![License](https://img.shields.io/badge/License-Restricted-red.svg)]()

A native macOS application built with **SwiftUI** that mixes two audio tracks:
a *background track* (“Original”) and a *voice track* (“Voice”).
The app includes an intelligent **ducking engine** that automatically lowers the background audio whenever voice is detected, resulting in a clear and well-balanced final mix.

---

## ✨ Key Features

* **File Selection**
  Import common audio formats: `.aiff`, `.m4a`, `.mp3`, `.wav`.

* **Intelligent Ducking**
  Automatically reduces the background audio to a low volume when voice activity is detected.

  * Normal volume: `1.0`
  * Ducking volume: `0.05`
  * Voice detection threshold: `-50 dB`

* **Audio Mixing Engine**
  Uses **AVFoundation** (`AVMutableComposition`, `AVAssetReader`, `AVAssetExportSession`) for precise mixing and export.

* **Asynchronous Processing**
  The UI remains responsive while the app processes and exports the final mix.

* **Export to M4A**
  Final output is saved as a high-quality `.m4a` file.

---

## 🖥️ Requirements

| Component | Minimum Version |
| --------- | --------------- |
| macOS     | 14.0 (Sonoma)   |
| Xcode     | 15.0            |
| Swift     | 5.9             |

---

## 🚀 Installation

```bash
git clone https://github.com/carlneto/AudioMixer.git
cd audio-mixer-app
open AudioMixerApp.xcodeproj
```

Then choose **My Mac** as the run destination and press **⌘R**.

---

## 🎙️ How to Use

1. **Select Original**
   Choose the background audio track (music, ambience, effects, etc.).

2. **Select Voice**
   Choose the voice track (narration, dialogue, podcast vocals, etc.).

3. **Select Output & Mix**
   Pick the destination file and start the mixing process.

The application will notify you when the export is complete or if an error occurs.

---

## 🧠 Ducking Logic (Simplified Example)

```swift
// Volume levels
let detectedVolume: Float = 0.05     // volume when voice is detected
let normalVolume: Float = 1.0        // volume when no voice is detected
let silenceThreshold: Float = -50.0  // dB threshold for silence

// ...
while assetReader.status == .reading {
    // Calculate RMS / dB from current audio buffer
    if db > silenceThreshold {
        // Voice detected
        parameters.setVolume(detectedVolume, at: currentTime)
    } else {
        // No voice
        parameters.setVolume(normalVolume, at: currentTime)
    }
    // Update currentTime for the next sample window
}
```

---

## 📂 Project Structure

| File / Folder           | Description                            |
| ----------------------- | -------------------------------------- |
| **AudioMixerApp.swift** | App entry point (SwiftUI).             |
| **ContentView.swift**   | Main UI for file selection and mixing. |
| **MixerEngine.swift**   | Core mixing logic using AVFoundation.  |
| **Resources/**          | Assets (icons, images, etc.).          |

---

## 🧪 Roadmap (Suggested Improvements)

* [ ] Waveform visualization
* [ ] Adjustable ducking parameters (threshold, fade in/out, ratio)
* [ ] Support for more export formats
* [ ] Preview playback before exporting
* [ ] Batch processing of multiple audio pairs

---

## ❗ License (Restricted Use)

This software is provided under a **Restricted-Use License**:

* **Prohibited:** modification, distribution, reverse engineering, sublicensing, public or private sharing, or commercial use without written permission.
* **Ownership:** all intellectual property belongs exclusively to the author.
* **Permitted Use:** strictly personal, private, non-commercial evaluation.
* **No Warranty:** provided *“as is”*.
* **Liability:** no responsibility for any direct or indirect damages.

For full terms, see the accompanying LICENSE file (not distributed).

---

## ✍️ Author

**carlneto — 2025**
Technologies: Swift, SwiftUI, AVFoundation

---
