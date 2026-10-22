# Productly — Flutter Product Explorer

**Productly** is a production-quality, elegant Flutter e-commerce product exploration application built according to **Clean Architecture** principles, strict Dependency Injection via **Injectable & GetIt**, robust state management using **Flutter BLoC**, and seamless routing with **GoRouter**.

The application integrates with the **DummyJSON Products API** featuring infinite scroll pagination, pull-to-refresh, complete product details, swipeable image galleries, full review breakdowns, product specifications, and QR code inspection.

---

## 📱 Screenshots & Screens Implemented

### 1. Splash Screen
- Minimal, warm-neutral background (`#FAFAF8`) with subtle mint-green decorative curves.
- Custom vector-drawn green shopping bag logo matching the visual design.
- Brand identity: **Productly** with tagline *"Discover products you'll love."*
- Smooth transition to the product list after initialization.

### 2. Product List Screen
- **Header**: Category discovery banner, "Explore Products" title, search & cart action icons.
- **Product Count Indicator**: Shows currently loaded vs total products (`Showing X of Y products`).
- **Two-Column Responsive Grid**: Card layout displaying product thumbnail, title, category/brand, star ratings & review counts, current price, strikethrough original price, discount percentage badges (`-24%`), and real-time stock indicators.
- **Pull-to-Refresh**: Resets pagination to `skip=0`, refreshes dataset, and safely replaces old list items.
- **Infinite Pagination**: Automatic scroll listener loads the next 10 items near the bottom (`skip = 10, 20, 30...`). Includes loading indicators, duplicate request prevention guards, and pagination retry controls on network failure.
- **Bottom Navigation**: 4-tab bar (Home, Categories, Wishlist, Profile) with active brand accent.

### 3. Product Details Screen
- **Zero-Network Detail Navigation**: Selected `ProductEntity` is passed directly through GoRouter `extra`.
- **Swipeable Image Gallery**: Full image carousel with page indicator dots, counter pill (`1/5`), thumbnail selector, and cached image fallback handling.
- **Main Information**: Title, brand, category, ratings, stock status, bold price, strikethrough original price, and percentage discount pill.
- **Product Specifications**: Tabular dimensions (width × height × depth), weight, SKU, minimum order quantity, and stock availability.
- **Shipping & Policies**: Dedicated sections for shipping duration, warranty coverage, and return policies.
- **Customer Reviews**: Complete list of user reviews displaying reviewer name, email, star rating, formatted dates, and comments.
- **Metadata**: Barcode, creation & update timestamps, and rendered QR Code image.
- **Additional Data**: Expandable accordion displaying any extra raw API parameters without loss.
- **Bottom Bar**: Sticky "Add to Cart" action button with user feedback.

---

## 🏛️ Clean Architecture & Project Structure

The project strictly follows Clean Architecture separation of concerns:

```
lib/
├── core/
│   ├── di/
│   │   └── register_module.dart       # Third-party registrations (@module for Dio)
│   ├── error/
│   │   ├── exceptions.dart            # ServerException, NetworkException, ParsingException
│   │   └── failures.dart              # Failure abstractions (ServerFailure, NetworkFailure)
│   ├── theme/
│   │   ├── app_colors.dart            # Design system palette (emerald, charcoal, neutrals)
│   │   └── app_theme.dart             # Material 3 typography, cards, and theme data
│   └── usecase/
│       └── usecase.dart               # UseCase<T, Params> base contract
├── features/
│   └── products/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── product_remote_data_source.dart  # Dio API implementation (@LazySingleton)
│       │   ├── models/
│       │   │   ├── product_dimensions_model.dart
│       │   │   ├── product_meta_model.dart
│       │   │   ├── product_model.dart               # Safe JSON parsing with fallback defaults
│       │   │   ├── product_response_model.dart      # Paginated response envelope
│       │   │   └── product_review_model.dart
│       │   └── repositories/
│       │       └── product_repository_impl.dart     # Either<Failure, ProductResponseEntity>
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── product_dimensions_entity.dart
│       │   │   ├── product_entity.dart              # Equatable product domain entity
│       │   │   ├── product_meta_entity.dart
│       │   │   ├── product_response_entity.dart
│       │   │   └── product_review_entity.dart
│       │   ├── repositories/
│       │   │   └── product_repository.dart          # Domain repository contract
│       │   └── usecases/
│       │       └── get_products_usecase.dart        # Paginated fetch usecase (@lazySingleton)
│       └── presentation/
│           ├── bloc/
│           │   ├── product_bloc.dart                # State machine & concurrency guards (@injectable)
│           │   ├── product_event.dart               # Initial, NextPage, Refresh, Retry
│           │   └── product_state.dart               # Immutable state with pagination flags
│           ├── screens/
│           │   ├── splash_screen.dart
│           │   ├── product_list_screen.dart
│           │   └── product_details_screen.dart
│           └── widgets/
│               ├── custom_bag_logo.dart
│               ├── error_view.dart
│               ├── pagination_loader.dart
│               ├── product_card.dart
│               ├── product_gallery.dart
│               ├── product_rating_bar.dart
│               ├── review_card.dart
│               ├── spec_section.dart
│               └── stock_badge.dart
├── routes/
│   └── app_router.dart                # GoRouter routing with typed extra passing
├── injection_container.dart           # Injectable initialization with GetIt
└── main.dart                          # App entry point
```

---

## 💉 Dependency Injection (Injectable + GetIt)

Dependency injection follows the reference specification and guide (`flutter-injectable-auto-di-bangla.md`):

1. **Third-Party Module (`RegisterModule`)**:
   - `Dio` is registered via `@module` in `lib/core/di/register_module.dart` with DummyJSON base URL (`https://dummyjson.com`), 15s timeouts, and JSON headers.
2. **Data Sources**:
   - `@LazySingleton(as: ProductRemoteDataSource)` on `ProductRemoteDataSourceImpl`.
3. **Repositories**:
   - `@LazySingleton(as: ProductRepository)` on `ProductRepositoryImpl`.
4. **Use Cases**:
   - `@lazySingleton` on `GetProductsUseCase`.
5. **BLoCs**:
   - `@injectable` on `ProductBloc` for factory instantiation.
6. **Code Generation**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   Generates `lib/injection_container.config.dart`.
7. **Initialization**:
   - `configureDependencies()` is called in `main()` before `runApp()`.
   - BLoC is provided to widget tree via `sl<ProductBloc>()`.

---

## 🔄 Pagination & State Management

- **API Endpoint**: `https://dummyjson.com/products?limit=10&skip=X`
- **Offset Progression**: Advances `skip` by 10 (`skip=0`, `skip=10`, `skip=20`, etc.).
- **Concurrency Guards**:
  - Drops pagination triggers if already fetching (`isLoading`, `isPaginationLoading`, `isRefreshing`).
  - Stops requests when `skip + products.length >= total` or when API returns empty page.
  - Deduplicates items by unique `id` to ensure key consistency.
- **Fault-Tolerant UX**:
  - When pagination fails, already-loaded items remain visible.
  - A retry button appears at the list footer.
  - Pull-to-refresh completely resets pagination and replaces dataset.

---

## 🧪 Testing & Verification

The test suite covers models, repository, usecase, BLoC state transitions, and UI smoke tests:

- **JSON Serialization Tests**: Verifies parsing of complete objects, nested dimensions, reviews, metadata, and handles missing/null optional fields safely.
- **Repository Unit Tests**: Validates `Right(ProductResponseModel)` on success and mapping of `NetworkException` and `ServerException` to `Failure` types.
- **UseCase Tests**: Confirms parameter forwarding.
- **BLoC Tests**: Verifies `ProductFetchInitial`, pagination offset progression, retaining products on pagination failure, pull-to-refresh state reset, and duplicate request blocking.
- **Widget Test**: Verifies `SplashScreen` rendering and brand elements.

### Run Verification Commands:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run DI code generator
dart run build_runner build --delete-conflicting-outputs

# 3. Format codebase
dart format lib test

# 4. Run static analysis
flutter analyze

# 5. Run all test suites
flutter test
```
