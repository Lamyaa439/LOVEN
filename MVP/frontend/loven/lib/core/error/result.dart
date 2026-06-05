import 'package:loven/core/error/app_exception.dart';

/// Result wrapper for success/failure flows in the data layer.
///
/// Repositories may return [Result] instead of throwing; not yet adopted app-wide.
/// 
/// ليش نحتاج ذا الملف ؟
/// try/catch عشان مب كل مرة نكتب 
/// try {
///  final user = await repository.getUser();
///   التطبيق يستمر هنا إذا نجح الطلب
/// } catch (e) {
///   إذا نسينا نكتب هذا الجزء، التطبيق ينهار!
/// }
///
/// اللي تجبرنا نكتب حالة النجاح والفشل when() بداله بنستخدم دالة 
/// عشان ماينهار التطبيق لو نسينا نعالج احد الحالتين
/// مثال للإستخدام:
/// final user = await repository.getUser();
/// 
/// result.when(
///   success: (artist) {
///        تنفيذ هذا الكود إذا كانت النتيجة Ok
///     emit(ProfileLoaded(artist));
///   },
///   failure: (error) {
///        تنفيذ هذا الكود إذا كانت النتيجة Err
///     emit(ProfileError(error.message));
///   },
/// );

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Ok<T>;
  bool get isFailure => this is Err<T>;

  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  AppException? get errorOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final error) => error,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      Ok<T>(:final value) => success(value),
      Err<T>(:final error) => failure(error),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);

  final AppException error;
}
