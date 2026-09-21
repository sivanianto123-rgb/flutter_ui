import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nike App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        textTheme: const TextTheme().copyWith().apply(fontFamily: 'Helvetica'),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_FavoritesScreenState> _favoritesKey = GlobalKey();
  final GlobalKey<_CartScreenState> _cartKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ProductListScreen(),
      FavoritesScreen(key: _favoritesKey),
      CartScreen(key: _cartKey),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      // Refresh the favorites screen when we navigate to it
      if (index == 1) {
        _favoritesKey.currentState?.refresh();
      }
      // Refresh the cart screen when we navigate to it
      if (index == 2) {
        _cartKey.currentState?.refresh();
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Shop'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool showAddedPopup = false;
  String popupMessage = '';

  void _showAddToCartSuccess() {
    setState(() {
      showAddedPopup = true;
      popupMessage = 'Successfully added to cart!';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showAddedPopup = false;
        });
      }
    });
  }

  void _showAddToFavoritesSuccess() {
    setState(() {
      showAddedPopup = true;
      popupMessage = 'Added to favorites!';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showAddedPopup = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'NIKE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Futura',
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'everyone flies... some fly longer than others',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hot Picks 🔥',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final products = [
                        {
                          'name': 'Kyrie 6',
                          'image':
                              'https://2.kixify.com/sites/default/files/imagecache/product_full/product/2022/09/27/p_34324225_198077016_111814.jpg',
                          'price': 14250,
                          'description':
                              'Bouncy cushioning is paired with soft yet supportive foam for responsiveness and smooth heel-to-toe transitions.',
                        },
                        {
                          'name': 'Zoom FREAK',
                          'image':
                              'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/48282e4d-bab1-46fa-93d3-8ac32f598c1b/custom-freak-5-by-you.png',
                          'price': 17850,
                          'description':
                              'The forward-thinking design of the latest signature shoe.',
                        },
                        {
                          'name': 'KD Treys',
                          'image':
                              'https://rukminim2.flixcart.com/image/750/900/xif0q/shoe/b/p/5/-original-imagx8gugpagxdhe.jpeg?q=20&crop=false',
                          'price': 18000,
                          'description':
                              'Lightweight, responsive cushioning for explosive moves.',
                        },
                        {
                          'name': 'Air Max',
                          'image':
                              'https://imgcentauro-a.akamaihd.net/900x900/93482632A4/tenis-nike-air-max-ltd-3-masculino-img.jpg',
                          'price': 16500,
                          'description':
                              'Classic style with modern comfort and innovative cushioning.',
                        },
                        {
                          'name': 'LeBron 18',
                          'image':
                              'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/24a62e35-a0ac-4bdb-b864-1e6ca358bc3b/LEBRON+XXII+QS+EP.png',
                          'price': 19500,
                          'description':
                              'Maximum support and cushioning for powerful players.',
                        },
                      ];

                      if (index < products.length) {
                        return ProductCard(
                          name: products[index]['name'] as String,
                          imageUrl: products[index]['image'] as String,
                          price: products[index]['price'] as int,
                          description: products[index]['description'] as String,
                          onAddToCart: _showAddToCartSuccess,
                          onAddToFavorites: _showAddToFavoritesSuccess,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'New Arrivals',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final products = [
                        {
                          'name': 'Air Jordan',
                          'image':
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLfxhAtzevA7YLJVDGfP9rRNwpIiFmw8U6rw&s',
                          'price': 18750,
                          'description':
                              'The legacy continues with modern updates to a classic.',
                        },
                        {
                          'name': 'Metcon 6',
                          'image':
                              'https://www.nike.ae/dw/image/v2/BDVB_PRD/on/demandware.static/-/Sites-akeneo-master-catalog/default/dw8b4aab82/nk/d78/7/3/1/0/7/d7873107_8b97_4cd2_a481_8be0a2cdda96.jpg?sw=700&sh=700&sm=fit&q=100&strip=false',
                          'price': 13500,
                          'description':
                              'Stability and durability for all your workouts.',
                        },
                        {
                          'name': 'React Infinity',
                          'image':
                              'https://rukminim2.flixcart.com/image/850/1000/xif0q/shoe/r/0/d/-original-imagx8gvcu9rtzvj.jpeg?q=90&crop=false',
                          'price': 15750,
                          'description':
                              'Designed to help reduce injury and keep you running.',
                        },
                        {
                          'name': 'Vaporfly',
                          'image':
                              'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/eb6cdeee-ef8c-4a7e-bd77-5dbc5843f6d4/ZOOMX+VAPORFLY+NEXT%25+3+FK+EK.png',
                          'price': 20250,
                          'description':
                              'Racing shoe with carbon fiber plate for speed.',
                        },
                        {
                          'name': 'Blazer Mid',
                          'image':
                              'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/edde6171-407b-42fc-b680-858e87462337/custom-nike-blazer-mid-77-shoes-by-you.png',
                          'price': 9750,
                          'description':
                              'Vintage look with contemporary comfort.',
                        },
                      ];

                      if (index < products.length) {
                        return ProductCard(
                          name: products[index]['name'] as String,
                          imageUrl: products[index]['image'] as String,
                          price: products[index]['price'] as int,
                          description: products[index]['description'] as String,
                          onAddToCart: _showAddToCartSuccess,
                          onAddToFavorites: _showAddToFavoritesSuccess,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (showAddedPopup)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        popupMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        popupMessage.contains('cart')
                            ? 'Check your cart'
                            : 'Check your favorites',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int price;
  final String description;
  final VoidCallback onAddToCart;
  final VoidCallback onAddToFavorites;

  const ProductCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.onAddToCart,
    required this.onAddToFavorites,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final favoritesManager = FavoritesManager();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = favoritesManager.isFavorite(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.grey[800],
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Text('Image not available'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            favoritesManager.toggleFavorite(
                              widget.name,
                              widget.price,
                              widget.imageUrl,
                              widget.description,
                            );
                            isFavorite = favoritesManager.isFavorite(
                              widget.name,
                            );
                          });
                          widget.onAddToFavorites();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${widget.price.toString()}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    CartManager().addToCart(
                      widget.name,
                      widget.price,
                      widget.imageUrl,
                    );
                    widget.onAddToCart();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final List<Map<String, dynamic>> _favoriteItems = [];

  List<Map<String, dynamic>> get favoriteItems => _favoriteItems;

  void toggleFavorite(
    String name,
    int price,
    String imageUrl,
    String description,
  ) {
    bool itemExists = false;
    int itemIndex = -1;

    for (int i = 0; i < _favoriteItems.length; i++) {
      if (_favoriteItems[i]['name'] == name) {
        itemExists = true;
        itemIndex = i;
        break;
      }
    }

    if (itemExists) {
      _favoriteItems.removeAt(itemIndex);
    } else {
      _favoriteItems.add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'description': description,
      });
    }
  }

  bool isFavorite(String name) {
    for (var item in _favoriteItems) {
      if (item['name'] == name) {
        return true;
      }
    }
    return false;
  }
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final favoritesManager = FavoritesManager();

  // Method to force refresh the screen
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          favoritesManager.favoriteItems.isEmpty
              ? const Center(child: Text('No favorites yet'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoritesManager.favoriteItems.length,
                itemBuilder: (context, index) {
                  final item = favoritesManager.favoriteItems[index];
                  return FavoriteItemWidget(
                    name: item['name'] as String,
                    price: item['price'] as int,
                    imageUrl: item['imageUrl'] as String,
                    description: item['description'] as String,
                    onRemove: () {
                      setState(() {
                        favoritesManager.toggleFavorite(
                          item['name'] as String,
                          item['price'] as int,
                          item['imageUrl'] as String,
                          item['description'] as String,
                        );
                      });
                    },
                    onAddToCart: () {
                      CartManager().addToCart(
                        item['name'] as String,
                        item['price'] as int,
                        item['imageUrl'] as String,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

class FavoriteItemWidget extends StatelessWidget {
  final String name;
  final int price;
  final String imageUrl;
  final String description;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const FavoriteItemWidget({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('No image'));
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toString()}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onRemove,
                        tooltip: 'Remove from favorites',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(String name, int price, String imageUrl) {
    bool itemExists = false;

    for (var item in _cartItems) {
      if (item['name'] == name) {
        item['quantity'] = (item['quantity'] as int) + 1;
        itemExists = true;
        break;
      }
    }

    if (!itemExists) {
      _cartItems.add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': 1,
      });
    }
  }

  void removeFromCart(String name) {
    _cartItems.removeWhere((item) => item['name'] == name);
  }

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += (item['price'] as int) * (item['quantity'] as int);
    }
    return total;
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartManager = CartManager();

  // Method to force refresh the screen
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('My Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                cartManager.cartItems.isEmpty
                    ? const Center(child: Text('Your cart is empty'))
                    : ListView.builder(
                      itemCount: cartManager.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartManager.cartItems[index];
                        return CartItemWidget(
                          name: item['name'] as String,
                          price: item['price'] as int,
                          imageUrl: item['imageUrl'] as String,
                          quantity: item['quantity'] as int,
                          onRemove: () {
                            setState(() {
                              cartManager.removeFromCart(
                                item['name'] as String,
                              );
                            });
                          },
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${cartManager.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // Checkout logic
                    },
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final String name;
  final int price;
  final String imageUrl;
  final int quantity;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('No image'));
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toString()}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    'Quantity: $quantity',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
