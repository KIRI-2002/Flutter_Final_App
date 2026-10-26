import 'package:bloc/bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';
import 'package:y3s1_final/bloc/product_state.dart';
import 'package:y3s1_final/models/cart_model.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductState()) {
    on<AddCartEvent>(_addCart);
    on<RemoveCartEvent>(_removeCart);
    on<UpdateQuantityEvent>(_updateQuantity);
    on<ClearCartEvent>((event, emit) {
      emit(state.copyWith(cartModel: const []));
    });
    on<IncrementEvent>((event, emit) {
      emit(state.copyWith(quantity: state.quantity + 1));
    });
    on<DescrementEvent>((event, emit) {
      emit(
        state.copyWith(quantity: state.quantity > 1 ? state.quantity - 1 : 1),
      );
    });
    on<ResetQuantityEvent>((event, emit) {
      emit(state.copyWith(quantity: 1));
    });
    on<SelectCategory>((event, emit) {
      emit(state.copyWith(selectedCategory: event.category));
    });
  }

  void _addCart(AddCartEvent event, Emitter<ProductState> emit) {
    final cart = List<CartModel>.from(state.cartModel);
    final existingIndex = cart.indexWhere(
      (item) =>
          item.product.code == event.product.code &&
          item.size == event.size &&
          item.color == event.color,
    );

    if (existingIndex == -1) {
      cart.add(
        CartModel(
          product: event.product,
          color: event.color,
          quantity: event.quantity,
          size: event.size,
        ),
      );
    } else {
      final existing = cart[existingIndex];
      cart[existingIndex] = existing.copyCart(
        quantity: existing.quantity + event.quantity,
      );
    }

    emit(state.copyWith(cartModel: cart));
  }

  void _removeCart(RemoveCartEvent event, Emitter<ProductState> emit) {
    final cart =
        state.cartModel.where((item) => item != event.removeCart).toList();
    emit(state.copyWith(cartModel: cart));
  }

  void _updateQuantity(UpdateQuantityEvent event, Emitter<ProductState> emit) {
    final cart =
        state.cartModel.map((item) {
          if (item == event.cartModel) {
            return item.copyCart(quantity: event.quantity);
          }
          return item;
        }).toList();

    emit(state.copyWith(cartModel: cart));
  }
}
