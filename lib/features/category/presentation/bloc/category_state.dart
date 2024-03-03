part of 'category_bloc.dart';

class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoriesLoading extends CategoryState{}

class CategoriesLoaded extends CategoryState{
  final List<Category> categories;

  const CategoriesLoaded({required this.categories});
  @override
  List<Object> get props => [categories];
}
