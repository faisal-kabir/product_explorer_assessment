import 'package:go_router/go_router.dart';

import '../features/products/domain/entities/product_entity.dart';
import '../features/products/presentation/screens/product_details_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/products/presentation/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String products = '/products';
  static const String productDetails = '/product-details';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: products,
        name: 'products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: productDetails,
        name: 'productDetails',
        builder: (context, state) {
          final product = state.extra is ProductEntity
              ? state.extra as ProductEntity
              : null;
          return ProductDetailsScreen(product: product);
        },
      ),
    ],
  );
}
