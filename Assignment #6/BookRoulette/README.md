# Book Roulette

Lab 6 · Favorites Roulette. A single-screen iOS app that shows a random card from my 10 favorite books: a cover image, a title and a short description. Every tap on the button picks a new book, never the same one twice in a row.

**Category:** books
**Stack:** Swift, UIKit, Storyboard (no Auto Layout), iOS 16+, iPhone only

## My top 10

1. Sans Famille: Hector Malot
2. L'Étranger: Albert Camus
3. Une Vie: Guy de Maupassant
4. La Curée: Émile Zola
5. To Kill a Mockingbird: Harper Lee
6. Les Misérables: Victor Hugo
7. Don Quixote: Miguel de Cervantes
8. The Picture of Dorian Gray: Oscar Wilde
9. Candide: Voltaire
10. Le Bourgeois gentilhomme: Molière

## Screenshots

| Launch screen | Main screen | Home Screen icon |
| --- | --- | --- |
| ![Launch screen](screenshots/launch.png) | ![Main screen](screenshots/main.png) | ![Home Screen with the icon](screenshots/home1.png) | And an extra SS for the app after I enter it

## Run it

1. Open `BookRoulette.xcodeproj` in Xcode.
2. Pick any iPhone simulator.
3. Press Run (⌘R).

## Project notes

- `Favorite.swift`: the `Favorite` struct (image name, title, description).
- `ViewController.swift`: the array of 10 favorites, the initial state and the random pick.
- `Main.storyboard`: image view, two labels and a button, laid out with autoresizing masks only (no constraints).
- `LaunchScreen.storyboard`: custom launch screen in the same colors as the app.
- `Assets.xcassets`: 10 cover images, a placeholder for the initial state and a 1024 × 1024 `AppIcon` without transparency.
