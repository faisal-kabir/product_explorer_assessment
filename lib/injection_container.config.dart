// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/di/register_module.dart' as _i854;
import 'features/products/data/datasources/product_remote_data_source.dart'
    as _i215;
import 'features/products/data/repositories/product_repository_impl.dart'
    as _i553;
import 'features/products/domain/repositories/product_repository.dart' as _i112;
import 'features/products/domain/usecases/get_products_usecase.dart' as _i320;
import 'features/products/presentation/bloc/product_bloc.dart' as _i276;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i215.ProductRemoteDataSource>(
      () => _i215.ProductRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i112.ProductRepository>(
      () => _i553.ProductRepositoryImpl(gh<_i215.ProductRemoteDataSource>()),
    );
    gh.lazySingleton<_i320.GetProductsUseCase>(
      () => _i320.GetProductsUseCase(gh<_i112.ProductRepository>()),
    );
    gh.factory<_i276.ProductBloc>(
      () =>
          _i276.ProductBloc(getProductsUseCase: gh<_i320.GetProductsUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i854.RegisterModule {}
