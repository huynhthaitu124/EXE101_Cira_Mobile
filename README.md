# Cira

A React Native mobile application built with TypeScript and Expo.

## Prerequisites

Before you begin, ensure you have the following installed:

- Node.js (>= 18)
- npm or yarn
- Expo Go app on your mobile device (for testing)
  - [iOS App Store](https://apps.apple.com/app/expo-go/id982107779)
  - [Google Play Store](https://play.google.com/store/apps/details?id=host.exp.exponent)

## Getting Started

### 1. Install Dependencies

```bash
npm install
```

or

```bash
yarn install
```

### 2. Start Development Server

```bash
npm start
```

This will open Expo Dev Tools in your browser.

### 3. Run on Your Device

#### Option A: Using Expo Go App (Recommended for development)

1. Install Expo Go on your mobile device
2. Scan the QR code shown in the terminal or browser
3. The app will load on your device

#### Option B: Using Emulator/Simulator

**iOS Simulator (macOS only):**
```bash
npm run ios
```

**Android Emulator:**
```bash
npm run android
```

**Web Browser:**
```bash
npm run web
```

## Project Structure

```
Cira/
├── src/
│   ├── components/    # Reusable React components
│   └── screens/       # Screen components
├── assets/           # Images, fonts, and other assets
├── __tests__/        # Test files
├── App.tsx           # Main application component
├── app.json          # Expo configuration
├── index.js          # Application entry point
└── package.json      # Project dependencies
```

## Available Scripts

- `npm start` - Start the Expo development server
- `npm run android` - Open on Android emulator
- `npm run ios` - Open on iOS simulator (macOS only)
- `npm run web` - Open in web browser
- `npm test` - Run tests
- `npm run lint` - Run ESLint

## Tech Stack

- **Expo** - Development platform for React Native
- **React Native** - Mobile framework
- **TypeScript** - Type-safe JavaScript
- **React** - UI library

## Development Guidelines

- Use TypeScript for type safety
- Follow React Native best practices
- Use functional components with hooks
- Maintain consistent code formatting with Prettier
- Follow ESLint rules

## Building for Production

### Create Production Build

**Android:**
```bash
npx expo build:android
```

**iOS:**
```bash
npx expo build:ios
```

For more information about building and deploying, see [Expo Documentation](https://docs.expo.dev/build/introduction/).

## Learn More

- [Expo Documentation](https://docs.expo.dev/)
- [React Native Documentation](https://reactnative.dev/)
- [TypeScript Documentation](https://www.typescriptlang.org/)
- [React Documentation](https://react.dev/)

## Troubleshooting

If you encounter any issues:

1. Clear the cache: `npm start -- --clear`
2. Delete `node_modules` and reinstall: `rm -rf node_modules && npm install`
3. Check the [Expo documentation](https://docs.expo.dev/troubleshooting/overview/)

## License

This project is private and not licensed for public use.
# EXE101_Cira_Mobile
