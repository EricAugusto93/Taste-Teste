# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a multi-platform restaurant discovery application called "Taste" with two main components:

1. **taste_app** - Main Flutter application for discovering restaurants with AI-powered search
2. **admin-panel** - Next.js web admin panel for managing restaurant data

Both applications connect to a shared Supabase backend with PostgreSQL database and use Google Maps integration.

## Development Commands

### Flutter Application (taste_app)

**Testing & Analysis:**
```bash
# Run tests
flutter test

# Run linting
flutter analyze

# Check for very good analysis violations
flutter analyze --fatal-infos
```

**Building:**

```bash
# Development build for web
flutter run -d chrome --dart-define=ENVIRONMENT=development

# Production build for web  
flutter run -d chrome --dart-define=ENVIRONMENT=production --release

# Using PowerShell scripts (Windows)
powershell -ExecutionPolicy Bypass -File scripts/build_debug.ps1
powershell -ExecutionPolicy Bypass -File scripts/build_release.ps1

# Build with environment-specific script
.\scripts\build.ps1 -Environment dev -Platform web -BuildType debug
.\scripts\build.ps1 -Environment prod -Platform android -BuildType release
```

**Dependencies:**
```bash
# Get dependencies
flutter pub get

# Generate code (with build_runner)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Admin Panel (Next.js)

```bash
# Development
cd admin-panel
npm run dev

# Building
npm run build
npm start

# Linting
npm run lint
```

## Architecture Overview

### taste_app Architecture (Advanced)
- **Clean Architecture** with domain/data/presentation layers
- **Dependency Injection** using get_it and injectable
- **State Management** with flutter_riverpod and flutter_bloc
- **Routing** with go_router and deep linking support
- **Multi-environment** support (development/staging/production)
- **Google Maps** integration with clustering and custom markers
- **AI-powered search** service integration
- **Performance monitoring** and analytics
- **Comprehensive testing** setup with unit/widget/integration tests


### Admin Panel Architecture
- **Next.js 14** with App Router
- **TypeScript** with strict type checking
- **Supabase integration** for CRUD operations
- **Admin authentication** with role-based access
- **Responsive design** with Tailwind CSS

## Key Configuration Files

### Environment Configuration

**taste_app:**
- Environment variables in `.env`, `.env.development`, `.env.production`
- Multi-environment setup with build-time configuration
- Google Maps API key configuration for web/mobile

**admin-panel:**
- `.env.local` with Supabase credentials
- Type-safe environment variable handling

### Database Schema

**Core Tables:**
- `restaurants` - Restaurant data with categories, location, tags
- `categories` - Restaurant categories with sort order
- `user_profiles` - User data and preferences  
- `admins` - Admin users for panel access
- `favorites` - User favorite restaurants

**Key Fields:**
- Restaurants have `category_id` (UUID), `latitude/longitude`, `tags` (array)
- Categories have `sort_order` for consistent display
- All tables use UUID primary keys

## Common Development Patterns

### Error Handling
- **taste_app**: Comprehensive error handling with custom exceptions and failures
- **admin-panel**: Toast notifications with error boundaries

### API Integration
- Both apps use Supabase for backend operations
- **taste_app**: Repository pattern with datasources and caching
- **admin-panel**: Server actions and client-side API calls

### State Management
- **taste_app**: Combination of Riverpod for simple state, Bloc for complex flows
- **admin-panel**: React state with context for auth

## Testing Guidelines

### taste_app Testing
- Unit tests for repositories, services, and use cases
- Widget tests for reusable components
- Integration tests for complete user flows
- Performance tests for map rendering and image loading
- Mockito for service mocking

### Test Commands
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/services/search_service_test.dart

# Run with coverage
flutter test --coverage
```

## Deployment Notes

### taste_app
- Multi-platform support (Web, Android, iOS)
- Environment-specific builds with dart-define
- Web deployment requires CORS configuration for Google Maps

### admin-panel
- Static export compatible for Vercel/Netlify
- Requires Supabase environment variables
- Admin users must be added to `admins` table manually

## Google Maps Integration

The taste_app uses Google Maps with:
- **API Keys**: Required for both web and mobile platforms
- **Configuration**: Platform-specific setup in `google_maps_config.dart` (taste_app)
- **Features**: Clustering, custom markers, location permissions
- **Fallback**: Map widgets gracefully handle API failures

## Supabase Integration

**Row Level Security (RLS)**:
- `restaurants` table: Public read access
- `categories` table: Public read access  
- `user_profiles` table: User can only access own data
- `admins` table: Admin access only

**Storage**:
- `images` bucket for restaurant photos
- Public read access, authenticated upload

## Performance Considerations

### taste_app
- Image caching with `cached_network_image`
- Lazy loading for restaurant lists
- Map clustering for better performance
- Hive for local data caching


## Security Notes

- Never commit API keys or secrets to repository
- Use environment variables for all sensitive configuration
- Supabase RLS policies enforce data access rules
- Admin panel requires email verification in `admins` table