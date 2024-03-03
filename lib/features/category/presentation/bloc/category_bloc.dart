import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:expense_tracker/features/category/data/datasources/local/category_local_datasource.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {

  CategoryLocalDataSource dataSource=CategoryLocalDataSourceImpl();

  CategoryBloc() : super(CategoryInitial()) {
    on<CategoryEvent>((event, emit) {
    });
    on<AddCategoryEvent>(_addCategory);
    on<GetAllCategoryEvent>(_getCategory);
  }

  Future<void> _addCategory(AddCategoryEvent event,Emitter<CategoryState> emit) async{
    var result=await dataSource.addCategory(event.id,event.category);
    emit(CategoriesLoaded(categories: result));
  }
  Future<void> _getCategory(GetAllCategoryEvent event,Emitter<CategoryState> emit) async{
    emit(CategoriesLoading());
    var result=await dataSource.getCategories();
    emit(CategoriesLoaded(categories: result));
  }
}
