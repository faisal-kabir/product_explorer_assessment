import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductFetchInitial extends ProductEvent {
  const ProductFetchInitial();
}

class ProductFetchNextPage extends ProductEvent {
  const ProductFetchNextPage();
}

class ProductRefresh extends ProductEvent {
  const ProductRefresh();
}

class ProductRetryPagination extends ProductEvent {
  const ProductRetryPagination();
}
