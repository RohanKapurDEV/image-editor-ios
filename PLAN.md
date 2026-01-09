# UIKit Port Plan

## Goals
- Reimplement the current SwiftUI experience in UIKit with the same behaviors and animations.
- Use UIKit-native patterns (view controllers, collection views, auto layout) for cleaner structure.
- Improve performance and clarity where SwiftUI required extra state or manual geometry plumbing.

## Current Behavior Summary (SwiftUI)
- Root layout is a custom slide-in sidebar (full-width) with dimming overlay.
- Main view shows a stack of selected photos animating in from random edges.
- Bottom message bar with a plus button toggles an iMessage-style photo picker.
- Photo picker supports collapsed horizontal strip and expanded grid view.
- Photos are loaded via `PHCachingImageManager`; full images animate into stack.
- Photo permission gating shows a simple authorization prompt.

## Proposed UIKit Architecture

### App/Scene Entry
- `AppDelegate` + `SceneDelegate` (or a single `@main` app delegate if no scenes):
  - Configure global `UINavigationBarAppearance` as in SwiftUI initializer.
  - Set root view controller to a custom `SidebarContainerViewController`.

### View Controllers
- `SidebarContainerViewController`
  - Hosts two children: `SidebarViewController` (inside `UINavigationController`) and `MainViewController` (inside `UINavigationController`).
  - Manages sidebar state, overlay, and pan gesture (left edge or full-screen pan).
  - Uses constraints to slide the main controller and a dimming view for overlay.

- `MainViewController`
  - Background stack area (`StackedImagesView`).
  - Bottom input bar (`MessageInputBarView`).
  - Bottom picker container (`PickerContainerView`) that expands/collapses.
  - Owns `PhotoLibraryManager` and handles selections.

- `SidebarViewController`
  - Placeholder list (“Creations”) in a simple table view or empty state.
  - Matches existing navigation title and close button.

### Views / Components
- `StackedImagesView`
  - Manages an array of `UIImageView` items layered in a container.
  - Adds new images offscreen with random start positions and rotates into place.

- `MessageInputBarView`
  - `UIButton` (toggle) + `UITextField` in a `UIStackView`.
  - Uses a capsule-like background for the text field.

- `PickerContainerView`
  - Contains a drag handle, a collection view, and handles height transitions.
  - Switches between layouts: collapsed horizontal and expanded grid.

- `PhotoCell` / `CameraCell`
  - UICollectionView cells with rounded corners and tap animations.
  - `CameraCell` maps to the system camera button placeholder.

### Services
- `PhotoLibraryManager` (UIKit)
  - Exposes `authorizationStatus`, `photos`, and image loading methods.
  - Notifies via delegate/closures rather than `@Observable`.
  - Optionally adopts `PHPhotoLibraryChangeObserver` to refresh on changes.

## UIKit-Friendly Cleanups / Improvements
- Replace SwiftUI manual geometry state with auto layout constraints and view bounds.
- Use `UICollectionViewCompositionalLayout` + diffable data source for the picker.
- Use `PHCachingImageManager` caching APIs for prefetching to reduce thumbnail delays.
- Use `UIViewPropertyAnimator` for interactive drawer and picker drag to simplify state.
- Centralize photo selection and animations in `MainViewController` instead of view-local state.

## Detailed Implementation Steps

1) Project scaffolding
- Add folders: `ViewControllers/`, `Views/`, `Services/`, `Models/`.
- Create UIKit entry (`AppDelegate`/`SceneDelegate`) and wire root controller.
- Remove SwiftUI `@main` entry if switching fully to UIKit.

2) Sidebar container
- Implement `SidebarContainerViewController` with two child nav controllers.
- Add dimming view and `UIPanGestureRecognizer` for slide-in.
- Use constraints to animate the main controller offset from 0 to `sidebarWidth`.

3) Main view layout
- Build `MainViewController` with a background `StackedImagesView`.
- Add `MessageInputBarView` and `PickerContainerView` anchored to bottom.
- Handle keyboard insets for the input bar if necessary.

4) Photo picker
- Implement a collection view with two layouts:
  - Collapsed: horizontal, fixed height.
  - Expanded: grid with fixed item size and spacing.
- Add drag handle with tap + pan to expand/collapse.
- Use diffable data source and prefetching.

5) Photo manager
- Port `PhotoLibraryManager` to UIKit with delegate/closure callbacks.
- Mirror authorization flow and refresh UI on status changes.
- Add thumbnail + full-size image loading using `PHCachingImageManager`.

6) Stacked image animation
- Create a new `UIImageView` for each selection.
- Start it offscreen with a random offset and rotation.
- Animate to center with spring timing and final rotation.
- Keep a fixed size (200x200) and rounded corners/shadow.

7) Navigation bar and toolbar items
- Configure navigation bar appearance in the app entry point.
- Add left menu button (open sidebar) and right close button (close sidebar).

8) Polish + parity checks
- Match spacing, corner radii, and animation timings to SwiftUI.
- Verify drag thresholds and velocity behavior for sidebar and picker.
- Confirm limited-photo authorization flows and empty states.

## Open Questions / Decisions
- Should the sidebar host a real list of “Creations,” or stay empty for now?
- Should camera functionality be implemented or remain stubbed?
- Is the picker meant to be visible above the keyboard or move with it?

