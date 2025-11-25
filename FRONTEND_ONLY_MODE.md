# Frontend-Only Mode

This app now supports running in **frontend-only mode** without requiring a backend server!

## How to Enable Frontend-Only Mode

1. Open `lib/core/config/app_config.dart`
2. Set `useLocalStorage = true`:
   ```dart
   static const bool useLocalStorage = true;
   ```

## How It Works

When `useLocalStorage = true`:
- ✅ **No backend required** - All data is stored locally using SharedPreferences
- ✅ **Login/Registration** - Users are stored locally (passwords are stored in plain text - for demo only!)
- ✅ **Activities** - All activities are saved to and loaded from local storage
- ✅ **Works offline** - The app works completely offline

## Features

### Authentication
- Register new users (stored locally)
- Login with registered users
- Auto-login after registration
- Logout (clears local tokens)

### Activities
- Create new activities
- View activity list
- Edit activities
- Delete activities
- All data persists in local storage

## Limitations in Local Mode

- ⚠️ **Password security**: Passwords are stored in plain text (for demo purposes only!)
- ⚠️ **No password reset**: Password reset functionality is disabled
- ⚠️ **No password editing**: Password editing is disabled
- ⚠️ **Data is device-specific**: Data doesn't sync across devices
- ⚠️ **No cloud backup**: Data is only stored on the device

## Switching Back to Backend Mode

To use the backend API again:
1. Open `lib/core/config/app_config.dart`
2. Set `useLocalStorage = false`:
   ```dart
   static const bool useLocalStorage = false;
   ```

## Data Storage

All data is stored in SharedPreferences:
- Activities: `local_activities` key
- Users: `local_users` key
- Tokens: `jwt` and `refreshToken` keys (same as backend mode)

## Testing

1. Enable frontend-only mode
2. Run the app
3. Register a new user
4. Login with that user
5. Create activities - they'll be saved locally!
6. Close and reopen the app - your data persists!

