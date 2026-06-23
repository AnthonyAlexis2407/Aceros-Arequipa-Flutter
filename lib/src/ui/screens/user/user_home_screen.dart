import 'package:flutter/material.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/product_repository.dart';
import '../../../core/models/product.dart';
import 'user_shell.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // Calculator state
  String _activeTab = 'CIMENTACIÓN'; // 'CIMENTACIÓN' or 'COLUMNAS'
  String _selectedElementType = 'Viga de Cimentación';
  
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  
  bool _showResults = false;
  int _cementBags = 0;
  double _sandM3 = 0.0;
  double _stoneM3 = 0.0;
  int _steelBars = 0;
  String _steelDescription = '';
  Product? _steelProduct;

  final List<String> _cimentacionElements = [
    'Viga de Cimentación',
    'Zapata Aislada',
    'Cimiento Corrido'
  ];

  final List<String> _columnasElements = [
    'Columna de Confinamiento',
    'Columna Estructural'
  ];

  @override
  void initState() {
    super.initState();
    _widthController.text = '0.30';
    _lengthController.text = '4.00';
  }

  @override
  void dispose() {
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  void _onTabChanged(String tab) {
    setState(() {
      _activeTab = tab;
      if (tab == 'CIMENTACIÓN') {
        _selectedElementType = _cimentacionElements.first;
        _widthController.text = '0.30';
        _lengthController.text = '4.00';
      } else {
        _selectedElementType = _columnasElements.first;
        _widthController.text = '0.25';
        _lengthController.text = '3.00';
      }
      _showResults = false;
    });
  }

  void _calculateQuantities() {
    final double? width = double.tryParse(_widthController.text);
    final double? length = double.tryParse(_lengthController.text);

    if (width == null || length == null || width <= 0 || length <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa dimensiones válidas mayores a 0.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _showResults = true;
      if (_activeTab == 'CIMENTACIÓN') {
        if (_selectedElementType == 'Viga de Cimentación') {
          // Volume = width * length * height (assumed 0.40m depth)
          final double vol = width * length * 0.40;
          _cementBags = (vol * 9.5).ceil(); // 9.5 bags per m3 for concrete f'c=210
          _sandM3 = vol * 0.52;
          _stoneM3 = vol * 0.53;
          
          // Main steel rebar calculation: 4 longitudinal bars of 1/2"
          // + stirrups every 20cm (0.2m)
          // 4 bars * length / 9m length per bar
          final double mainRebars = (length * 4) / 9.0;
          final double stirrupsCount = length / 0.20;
          final double stirrupLength = (width * 2 + 0.40 * 2) + 0.10; // perimeter + hooks
          final double stirrupsBars = (stirrupsCount * stirrupLength) / 9.0;
          
          _steelBars = (mainRebars + stirrupsBars).ceil();
          _steelDescription = 'Varillas de Fierro Corrugado 1/2" (9m)';
          _steelProduct = ProductRepository.instance.findById('hierro-1-2');
        } else if (_selectedElementType == 'Zapata Aislada') {
          // Zapata (width x length x 0.60m depth)
          final double vol = width * length * 0.60;
          _cementBags = (vol * 9.5).ceil();
          _sandM3 = vol * 0.52;
          _stoneM3 = vol * 0.53;
          
          // Steel grids in both directions every 15cm (0.15m) using 5/8" rebar
          // Number of bars in width direction = (width / 0.15) * length
          // Number of bars in length direction = (length / 0.15) * width
          final double barsWidth = (width / 0.15) * length;
          final double barsLength = (length / 0.15) * width;
          _steelBars = ((barsWidth + barsLength) / 9.0).ceil();
          
          _steelDescription = 'Varillas de Fierro Corrugado 5/8" (9m)';
          _steelProduct = ProductRepository.instance.findById('hierro-5-8');
        } else {
          // Cimiento Corrido (width x length x 0.80m depth)
          final double vol = width * length * 0.80;
          _cementBags = (vol * 6.0).ceil(); // lower ratio for foundation f'c=100
          _sandM3 = vol * 0.50;
          _stoneM3 = vol * 0.80;
          
          // Basic longitudinal reinforcement 3/8"
          _steelBars = ((length * 4) / 9.0).ceil();
          _steelDescription = 'Varillas de Fierro Corrugado 3/8" (9m)';
          _steelProduct = ProductRepository.instance.findById('hierro-3-8');
        }
      } else { // COLUMNAS
        final double height = length; // length acts as height for columns
        if (_selectedElementType == 'Columna Estructural') {
          // Structural square column (width x width x height)
          final double vol = width * width * height;
          _cementBags = (vol * 10.0).ceil(); // f'c=280 structural concrete
          _sandM3 = vol * 0.48;
          _stoneM3 = vol * 0.48;
          
          // 6 main bars of 5/8" + stirrups 3/8" every 15cm
          final double mainRebars = (height * 6) / 9.0;
          final double stirrupsCount = height / 0.15;
          final double stirrupLength = (width * 4) + 0.10;
          final double stirrupsBars = (stirrupsCount * stirrupLength) / 9.0;
          
          _steelBars = (mainRebars + stirrupsBars).ceil();
          _steelDescription = 'Varillas de Fierro Corrugado 5/8" (9m)';
          _steelProduct = ProductRepository.instance.findById('hierro-5-8');
        } else {
          // Columna de Confinamiento (width x 0.15m x height)
          final double vol = width * 0.15 * height;
          _cementBags = (vol * 9.5).ceil();
          _sandM3 = vol * 0.52;
          _stoneM3 = vol * 0.53;
          
          // 4 main bars of 1/2" + stirrups 1/4" every 20cm
          final double mainRebars = (height * 4) / 9.0;
          final double stirrupsCount = height / 0.20;
          final double stirrupLength = (width * 2 + 0.15 * 2) + 0.10;
          final double stirrupsBars = (stirrupsCount * stirrupLength) / 9.0;
          
          _steelBars = (mainRebars + stirrupsBars).ceil();
          _steelDescription = 'Varillas de Fierro Corrugado 1/2" (9m)';
          _steelProduct = ProductRepository.instance.findById('hierro-1-2');
        }
      }
    });
  }

  void _addSteelToCart() {
    if (_steelProduct == null || _steelBars <= 0) return;
    
    // Add multiple quantities
    for (int i = 0; i < _steelBars; i++) {
      CartService.instance.addProduct(_steelProduct!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡$_steelBars varillas de ${_steelProduct!.name} añadidas al carrito!'),
        backgroundColor: const Color(0xFF001B5A),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VER CARRITO',
          textColor: Colors.white,
          onPressed: () {
            final shellState = context.findAncestorStateOfType<UserShellState>();
            if (shellState != null) {
              shellState.setSelectedIndex(2);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BIENVENIDO DE NUEVO',
                  style: TextStyle(
                    color: Color(0xFF0A3D91),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hola, Constructor',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ],
            ),
          ),

          // 2. Price Ticker Section
          _buildPriceTicker(),

          const SizedBox(height: 16),

          // 3. Promociones del Mes Header & Carousel
          _buildPromocionesHeader(),
          _buildPromocionesCarousel(),

          const SizedBox(height: 24),

          // 4. Categorías Destacadas
          _buildCategoriasDestacadas(),

          const SizedBox(height: 24),

          // 5. Calculadora de Materiales
          _buildCalculadora(),

          const SizedBox(height: 24),

          // 6. Novedades del Sector
          _buildNovedades(),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // Widget helpers: Ticker
  Widget _buildPriceTicker() {
    final List<Map<String, dynamic>> tickerItems = [
      {'name': 'ACERO 5/8"', 'price': 'S/ 48.50', 'up': true},
      {'name': 'PLANCHA LA 1/8"', 'price': 'S/ 124.00', 'up': false},
      {'name': 'PERFILES 2"', 'price': 'S/ 82.20', 'up': true},
      {'name': 'TUBERÍAS 2"', 'price': 'S/ 54.10', 'up': true},
      {'name': 'CLAVOS 3"', 'price': 'S/ 12.50', 'up': true},
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tickerItems.length,
        itemBuilder: (context, index) {
          final item = tickerItems[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  color: const Color(0xFF0A3D91),
                ),
                const SizedBox(width: 8),
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item['price'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  item['up'] ? Icons.trending_up : Icons.trending_down,
                  color: item['up'] ? Colors.green : Colors.red,
                  size: 14,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget helpers: Promociones Header
  Widget _buildPromocionesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF001B5A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Promociones del Mes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001B5A),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              final shellState = context.findAncestorStateOfType<UserShellState>();
              if (shellState != null) {
                shellState.setSelectedIndex(1);
              }
            },
            child: const Text(
              'VER TODAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helpers: Promociones Carousel
  Widget _buildPromocionesCarousel() {
    final List<Map<String, String>> promos = [
      {
        'tag': 'OFERTA TÉCNICA',
        'title': 'Combo Cimentación',
        'desc': 'Ahorra 15% en fierro corrugado y alambre negro #16.',
        'imageUrl': 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?q=80&w=600&auto=format&fit=crop',
      },
      {
        'tag': 'DESCUENTO DE TEMPORADA',
        'title': 'Planchas Estructurales',
        'desc': '10% de descuento en planchas LA A36 a partir de 5 unidades.',
        'imageUrl': 'https://images.unsplash.com/photo-1508849789987-4e5333c12b78?q=80&w=600&auto=format&fit=crop',
      }
    ];

    return Container(
      height: 195,
      margin: const EdgeInsets.only(top: 4),
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(promo['imageUrl']!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.65),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3D91),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        promo['tag']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      promo['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      promo['desc']!,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BAA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'COTIZAR AHORA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget helpers: Categorías Destacadas
  Widget _buildCategoriasDestacadas() {
    final List<Map<String, dynamic>> cats = [
      {
        'title': 'Fierro de construcción',
        'desc': 'Resistencia y ductilidad garantizada para obras seguras.',
        'imageUrl': 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?q=80&w=400&auto=format&fit=crop',
        'isSolid': false,
      },
      {
        'title': 'Perfiles',
        'desc': 'Ángulos, canales y vigas para estructuras metálicas.',
        'imageUrl': '',
        'icon': Icons.architecture,
        'isSolid': false,
      },
      {
        'title': 'Planchas',
        'desc': 'Laminadas en caliente y frío para toda aplicación industrial.',
        'imageUrl': '',
        'icon': Icons.layers,
        'isSolid': false,
      },
      {
        'title': 'Tubos y Tuberías',
        'desc': 'Variedad de diámetros y espesores para fluidos y estructuras.',
        'imageUrl': '',
        'icon': Icons.grid_view_rounded,
        'isSolid': true,
      }
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF001B5A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Categorías Destacadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001B5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category 1: Fierro de construcción
          _buildFierroCategoryCard(cats[0]),
          const SizedBox(height: 12),
          // Sub Category: Perfiles
          _buildSubCategoryCard(cats[1]),
          const SizedBox(height: 12),
          // Sub Category: Planchas
          _buildSubCategoryCard(cats[2]),
          const SizedBox(height: 12),
          // Sub Category Solid: Tubos y Tuberías
          _buildTubosCategoryCard(cats[3]),
        ],
      ),
    );
  }

  Widget _buildFierroCategoryCard(Map<String, dynamic> cat) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001B5A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cat['desc'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Image.network(
            cat['imageUrl'],
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCard(Map<String, dynamic> cat) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001B5A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat['desc'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              cat['icon'] as IconData,
              color: const Color(0xFFBFCFEF),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTubosCategoryCard(Map<String, dynamic> cat) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A3D91), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['desc'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            cat['icon'] as IconData,
            color: Colors.white.withValues(alpha: 0.4),
            size: 32,
          ),
        ],
      ),
    );
  }

  // Widget helpers: Calculadora
  Widget _buildCalculadora() {
    final bool isCimentacion = _activeTab == 'CIMENTACIÓN';
    final List<String> dropdownItems = isCimentacion ? _cimentacionElements : _columnasElements;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0EA), // greyish beige card as in screenshot
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E1DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calculadora de Materiales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001B5A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Optimiza tu presupuesto. Calcula la cantidad exacta de acero, cemento y agregados para tus zapatas, columnas y vigas.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          
          // Tab selection buttons
          Row(
            children: [
              Expanded(
                child: _buildCalcTabButton('CIMENTACIÓN', isCimentacion),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCalcTabButton('COLUMNAS', !isCimentacion),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Dropdown - Tipo de Elemento
          const Text(
            'TIPO DE ELEMENTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001B5A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dropdownItems.contains(_selectedElementType) 
                    ? _selectedElementType 
                    : dropdownItems.first,
                isExpanded: true,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                items: dropdownItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedElementType = newValue;
                      _showResults = false;
                    });
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Text Fields - Dimensions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCimentacion ? 'ANCHO (M)' : 'SECCIÓN (M)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001B5A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _widthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      onChanged: (_) => setState(() => _showResults = false),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCimentacion ? 'LARGO (M)' : 'ALTURA (M)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001B5A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _lengthController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      onChanged: (_) => setState(() => _showResults = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Calculate Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _calculateQuantities,
              icon: const Icon(Icons.calculate_outlined, color: Colors.white),
              label: const Text(
                'CALCULAR CANTIDADES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B), // Dark background as in screenshot
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Results view
          if (_showResults) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados Estimados:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001B5A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(Icons.widgets_outlined, 'Fierro Corregado Aceros Arequipa', '$_steelBars varillas', subText: _steelDescription),
                  const Divider(height: 16),
                  _buildResultRow(Icons.inventory_2_outlined, 'Cemento Sol f\'c=210', '$_cementBags bolsas'),
                  const Divider(height: 16),
                  _buildResultRow(Icons.opacity_outlined, 'Arena Gruesa', '${_sandM3.toStringAsFixed(2)} m³'),
                  const Divider(height: 16),
                  _buildResultRow(Icons.layers_outlined, 'Piedra Chancada', '${_stoneM3.toStringAsFixed(2)} m³'),
                  
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _addSteelToCart,
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text(
                        'AGREGAR ACERO AL CARRITO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0A3D91),
                        side: const BorderSide(color: Color(0xFF0A3D91), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalcTabButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => _onTabChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.white : const Color(0xFFCBD5E1),
            width: 1,
          ),
          boxShadow: isActive 
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'CIMENTACIÓN' ? Icons.foundation : Icons.table_bar,
              size: 16,
              color: isActive ? const Color(0xFF0A3D91) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF0A3D91) : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String title, String value, {String? subText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0A3D91), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              if (subText != null) ...[
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001B5A),
          ),
        ),
      ],
    );
  }

  // Widget helpers: Novedades
  Widget _buildNovedades() {
    final List<Map<String, String>> articles = [
      {
        'tag': 'SOSTENIBILIDAD',
        'title': 'Hacia la construcción con acero azul en Perú',
        'desc': 'Conoce nuestras iniciativas para reducir la huella de carbono en la producción siderúrgica nacional.',
        'imageUrl': 'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=600&auto=format&fit=crop',
      },
      {
        'tag': 'TÉCNICO',
        'title': 'Nuevas normas de sismoresistencia 2024',
        'desc': 'Análisis de los cambios normativos y cómo asegurar tus proyectos utilizando materiales certificados.',
        'imageUrl': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop',
      }
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF001B5A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Novedades del Sector',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001B5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildArticleCard(articles[0]),
          const SizedBox(height: 16),
          _buildArticleCard(articles[1]),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, String> art) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            art['imageUrl']!,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  art['tag']!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  art['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001B5A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  art['desc']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.3,
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
