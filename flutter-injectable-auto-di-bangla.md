# `injectable` + `build_runner` দিয়ে Dependency Injection Auto-Generate করা (বাংলা গাইড)

আগের `injection_container.dart` এ আমরা **হাতে (manually)** প্রতিটা ক্লাস `sl.registerLazySingleton(...)` লিখে রেজিস্টার করেছিলাম। এখন আমরা **`injectable`** প্যাকেজ ব্যবহার করে এটা **auto-generate** করবো — শুধু ক্লাসের উপরে একটা **Annotation** (যেমন `@injectable`, `@LazySingleton`) বসিয়ে দিলেই `build_runner` বাকি কোড নিজে বানিয়ে দেবে।

---

## ১. কোন কোন প্যাকেজ লাগবে

```yaml
dependencies:
  get_it: ^7.7.0
  injectable: ^2.4.4

dev_dependencies:
  build_runner: ^2.4.13
  injectable_generator: ^2.6.2
```

```bash
flutter pub get
```

---

## ২. কোন কোন জায়গায় পরিবর্তন লাগবে — সংক্ষেপে

| ফাইল | আগে যা করতেন | এখন যা করবেন |
|---|---|---|
| `AuthRemoteDataSourceImpl` | কিছুই না | ক্লাসের উপরে `@LazySingleton(as: AuthRemoteDataSource)` |
| `AuthRepositoryImpl` | কিছুই না | ক্লাসের উপরে `@LazySingleton(as: AuthRepository)` |
| `LoginUseCase` | কিছুই না | ক্লাসের উপরে `@lazySingleton` |
| `AuthBloc` | কিছুই না | ক্লাসের উপরে `@injectable` |
| `Dio` (থার্ড-পার্টি ক্লাস, annotation বসানো যায় না) | manual register | একটা **`@module`** ক্লাস বানিয়ে সেখানে register করতে হবে |
| `injection_container.dart` | সব `sl.register...()` লাইন হাতে লেখা | শুধু `@InjectableInit()` + `configureDependencies()` ফাংশন |
| নতুন ফাইল `injection_container.config.dart` | ছিল না | **build_runner অটো জেনারেট করবে** (হাত দেবেন না) |
| `main.dart` | `initAuthFeature();` | `configureDependencies();` |

চলুন এক এক করে ফাইলগুলো দেখি।

---

## ৩. Domain/Data লেয়ারের ক্লাসগুলোতে Annotation বসানো

### ৩.১ DataSource — `AuthRemoteDataSourceImpl`

**আগে:**
```dart
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);
  ...
}
```

**এখন:**
```dart
// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

@LazySingleton(as: AuthRemoteDataSource)   // 👈 নতুন লাইন
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);      // constructor আগের মতোই, কিছু বদলাতে হবে না

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw ServerException();
    }
  }
}

class ServerException implements Exception {}
```

> `@LazySingleton(as: AuthRemoteDataSource)` মানে হলো — "এই `Impl` ক্লাসটাকে register করো, কিন্তু যখন কেউ `AuthRemoteDataSource` (abstraction) চাইবে, তখন এটা দিয়ে দাও।" এটাই আগে আমরা manually `sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()))` লিখে করতাম।

### ৩.২ Repository — `AuthRepositoryImpl`

**এখন:**
```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)   // 👈 নতুন লাইন
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);   // constructor অপরিবর্তিত

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(email: email, password: password);
      return Right(user);
    } on ServerException {
      return const Left(ServerFailure('লগইন ব্যর্থ হয়েছে'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
}
```

### ৩.৩ UseCase — `LoginUseCase`

UseCase এর কোনো Abstraction/Interface অন্য কোথাও ইনজেক্ট হয় না (সরাসরি ক্লাস হিসেবেই ব্যবহার হয়), তাই এখানে `as:` লাগবে না — শুধু `@lazySingleton` বা `@injectable`।

```dart
// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton   // 👈 নতুন লাইন (lowercase — এটা একটা const instance, ক্লাস অ্যানোটেশন না)
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);   // constructor অপরিবর্তিত

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(email: params.email, password: params.password);
  }
}

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}
```

> **টিপস:** `@lazySingleton` (ছোট হাতের) একটা ready-made instance/annotation object, আর `@LazySingleton(...)` (বড় হাতের) হলো ক্লাস — যেটাতে `as:` এর মতো প্যারামিটার দেওয়া যায়। দুটোই একই কাজ করে, শুধু সিনট্যাক্স আলাদা।

### ৩.৪ BLoC — `AuthBloc`

BLoC সাধারণত প্রতিবার নতুন instance হিসেবে চাই (বিশেষ করে যদি একাধিক স্ক্রিনে আলাদা state লাগে), তাই এখানে `@injectable` ব্যবহার করি (এটা factory-এর মতো কাজ করে, singleton না)।

```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable   // 👈 নতুন লাইন — registerFactory এর সমতুল্য
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

> নিয়ম মনে রাখুন: `@injectable` = `registerFactory` (প্রতিবার নতুন instance), `@lazySingleton` / `@singleton` = `registerLazySingleton` / `registerSingleton` (একবারই instance বানায়, বারবার একই instance রিটার্ন করে)।

---

## ৪. থার্ড-পার্টি ক্লাসের জন্য (`Dio`) — `@module` ব্যবহার

`Dio` একটা external package এর ক্লাস, এর সোর্স কোডে গিয়ে annotation বসানো যাবে না। এজন্য একটা আলাদা **module** ফাইল বানাতে হয়:

```dart
// lib/core/di/register_module.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio(
        BaseOptions(
          baseUrl: 'https://your-api-base-url.com',
          connectTimeout: const Duration(seconds: 10),
        ),
      );
}
```

> যেকোনো থার্ড-পার্টি ক্লাস (যেমন `SharedPreferences`, `FirebaseAuth`, `Dio` ইত্যাদি) — যেগুলোর সোর্স কোড এডিট করা যায় না — সেগুলোর জন্য এভাবে `@module` ক্লাসে গেটার/মেথড বানিয়ে register করতে হয়।

---

## ৫. `injection_container.dart` — এখন অনেক ছোট হয়ে যাবে

**আগে (manual, ৩০+ লাইন):**
```dart
void initAuthFeature() {
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton(() => Dio());
}
```

**এখন (মাত্র কয়েক লাইন):**
```dart
// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';   // 👈 build_runner এটা অটো বানাবে

final sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init',      // অটো-জেনারেটেড init() ফাংশনের নাম
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => sl.init();   // 👈 এই একটা কলেই সব ফিচারের সব ক্লাস রেজিস্টার হয়ে যাবে
```

> **গুরুত্বপূর্ণ:** এখন এই ফাইলে `auth`, `todo` বা ভবিষ্যতে যত ফিচার যোগ করবেন — **সবগুলোর জন্য আলাদা `initXxxFeature()` ফাংশন লেখা লাগবে না।** `injectable` পুরো `lib/` ফোল্ডার স্ক্যান করে যেসব ক্লাসে `@injectable` / `@lazySingleton` / `@LazySingleton(as: ...)` / `@module` পাবে, সব এক জায়গায় জেনারেট করে দেবে।

---

## ৬. Command চালানো — কোড জেনারেট করা

```bash
dart run build_runner build --delete-conflicting-outputs
```

এই কমান্ড চালালে **`injection_container.config.dart`** নামে একটা নতুন ফাইল অটো তৈরি হবে (এটা আপনি কখনো হাতে এডিট করবেন না, এটা generated file)। এর ভিতরে মোটামুটি এরকম কোড থাকবে (উদাহরণ, পুরোটা আরও বড়):

```dart
// injection_container.config.dart (AUTO-GENERATED — এটা এডিট করবেন না)
extension GetItInjectableX on GetIt {
  GetIt init({String? environment, EnvironmentFilter? environmentFilter}) {
    final gh = GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();

    gh.lazySingleton<Dio>(() => registerModule.dio);
    gh.lazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(gh<Dio>()));
    gh.lazySingleton<AuthRepository>(() => AuthRepositoryImpl(gh<AuthRemoteDataSource>()));
    gh.lazySingleton<LoginUseCase>(() => LoginUseCase(gh<AuthRepository>()));
    gh.factory<AuthBloc>(() => AuthBloc(loginUseCase: gh<LoginUseCase>()));

    return this;
  }
}
```

> এটাই আপনার আগের `injection_container.dart` এ যা হাতে লিখতেন, তার সমতুল্য কোড — শুধু এখন Machine এটা নিজে লিখে দিলো।

**Development এর সময়** যদি চান কোড পরিবর্তন করার সাথে সাথে অটো re-generate হোক (manually কমান্ড না চালিয়ে):

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## ৭. `main.dart` এ পরিবর্তন

**আগে:**
```dart
void main() {
  initAuthFeature();
  runApp(const MyApp());
}
```

**এখন:**
```dart
import 'injection_container.dart';

void main() {
  configureDependencies();   // 👈 শুধু এই একটা কল, সব ফিচারের জন্য কমন
  runApp(const MyApp());
}
```

BLoC ব্যবহারের জায়গায় (UI তে) **কোনো পরিবর্তন লাগবে না**:
```dart
BlocProvider(
  create: (_) => sl<AuthBloc>(),
  child: LoginPage(),
)
```

---

## ৮. Multi-Feature প্রজেক্টে কীভাবে কাজ করে (যেমন `todo` ফিচার যোগ করলে)

ধরুন আপনি `todo` ফিচারও একইভাবে annotation দিয়ে দিলেন:

```dart
@LazySingleton(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository { ... }

@lazySingleton
class GetTodosUseCase implements UseCase<List<TodoEntity>, NoParams> { ... }

@injectable
class TodoBloc extends Bloc<TodoEvent, TodoState> { ... }
```

এরপর আপনাকে **আলাদা কোনো `initTodoFeature()`** বানাতে হবে না। শুধু আবার এই কমান্ড চালালেই হবে:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`injection_container.config.dart` অটোমেটিক্যালি `TodoBloc`, `GetTodosUseCase`, `TodoRepositoryImpl` সব যোগ করে দেবে একই ফাইলে। এটাই মূল সুবিধা — যত ফিচার বাড়বে, DI ফাইল ম্যানুয়ালি বড় করা লাগবে না।

---

## ৯. পুরো পরিবর্তনের চেকলিস্ট (সংক্ষেপে)

- [ ] `pubspec.yaml` এ `injectable`, `injectable_generator`, `build_runner` যোগ করুন এবং `flutter pub get` চালান
- [ ] প্রতিটা `RepositoryImpl` ক্লাসে `@LazySingleton(as: XxxRepository)` বসান
- [ ] প্রতিটা `DataSourceImpl` ক্লাসে `@LazySingleton(as: XxxDataSource)` বসান
- [ ] প্রতিটা `UseCase` ক্লাসে `@lazySingleton` বসান
- [ ] প্রতিটা `Bloc` ক্লাসে `@injectable` বসান
- [ ] থার্ড-পার্টি ডিপেন্ডেন্সি (Dio, SharedPreferences ইত্যাদি) এর জন্য একটা `@module` ক্লাস বানান
- [ ] পুরনো ম্যানুয়াল `injection_container.dart` মুছে ফেলে `@InjectableInit()` দিয়ে ছোট ভার্সন লিখুন
- [ ] `dart run build_runner build --delete-conflicting-outputs` চালান
- [ ] `main.dart` এ `initAuthFeature()` এর বদলে `configureDependencies()` কল করুন
- [ ] যতবার নতুন `@injectable`/`@lazySingleton` ক্লাস যোগ করবেন বা constructor বদলাবেন, **build_runner আবার চালাতে হবে**

---

## ১০. সতর্কতা / সাধারণ ভুল

1. **Interface এর ওপর `@LazySingleton` বসাবেন না** — এটা সবসময় **Impl ক্লাসের** উপর বসাতে হবে, `as:` প্যারামিটারে Abstraction/Interface দিতে হবে।
2. **`injection_container.config.dart` কখনো হাতে এডিট করবেন না** — build_runner চালালে এটা পুরোপুরি আবার তৈরি হয়ে যাবে, আপনার ম্যানুয়াল পরিবর্তন হারিয়ে যাবে।
3. Constructor এ কোনো নতুন dependency (parameter) যোগ করলে অবশ্যই আবার `build_runner build` চালাতে হবে, নাহলে পুরনো generated কোড অনুযায়ী inject হবে এবং error আসবে।
4. একই Interface এর একাধিক Implementation থাকলে (যেমন `Test` আর `Prod` এনভায়রনমেন্টের জন্য), `@Environment('dev')` / `@Environment('prod')` annotation ব্যবহার করতে হয় — এটা দরকার হলে জানাবেন, আলাদাভাবে দেখিয়ে দেব।
