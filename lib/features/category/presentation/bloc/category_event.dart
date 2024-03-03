part of 'category_bloc.dart';

class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class AddCategoryEvent extends CategoryEvent{
  final String id;
  final Category category;

  const AddCategoryEvent({required this.id,required this.category});
}

class GetAllCategoryEvent extends CategoryEvent{
  
}
