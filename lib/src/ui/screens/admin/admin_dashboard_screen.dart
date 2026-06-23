import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/product_repository.dart';
import '../../../core/models/product.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  String? _editingProductId;

  // Input Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gradoController = TextEditingController(text: 'Grado 60');
  final TextEditingController _diametroController = TextEditingController(text: '3/8"');
  final TextEditingController _longitudController = TextEditingController(text: '9.00');
  final TextEditingController _pesoController = TextEditingController(text: '0.56');
  final TextEditingController _precioController = TextEditingController(text: '48.50');
  final TextEditingController _stockController = TextEditingController(text: '100');

  // Dropdown and selector states
  String _category = 'Barras de Construcción';
  String _unitOfMeasure = 'MT'; // MT, KG, UND
  bool _hasFicha = false;
  bool _hasImage = false;
  
  String? _imageBase64;
  String? _pdfBase64;
  String? _pdfName;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _gradoController.dispose();
    _diametroController.dispose();
    _longitudController.dispose();
    _pesoController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate registration progress dynamically
  int _calculateProgress() {
    int score = 0;
    
    // 1. General Info (Name and Category)
    if (_nameController.text.trim().isNotEmpty) {
      score += 25;
    }
    
    // 2. Unit of Measure & Specs (Grado, Diametro, etc. are filled)
    if (_gradoController.text.isNotEmpty &&
        _diametroController.text.isNotEmpty &&
        _longitudController.text.isNotEmpty &&
        _pesoController.text.isNotEmpty) {
      score += 50; // Specs are filled
    } else {
      score += 25; // Partially filled specs
    }

    // 3. Ficha Técnica
    if (_hasFicha) {
      score += 25;
    }

    return score.clamp(0, 100);
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos obligatorios.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    double diamVal = 0.375; // default 3/8"
    final cleanDiam = _diametroController.text.replaceAll('"', '').trim();
    if (cleanDiam == '1/2') {
      diamVal = 0.5;
    } else if (cleanDiam == '5/8') {
      diamVal = 0.625;
    } else if (cleanDiam == '3/4') {
      diamVal = 0.75;
    } else if (cleanDiam == '1') {
      diamVal = 1.0;
    } else {
      diamVal = double.tryParse(cleanDiam) ?? 0.375;
    }

    final double price = double.tryParse(_precioController.text) ?? 48.50;
    final int stockVal = int.tryParse(_stockController.text) ?? 100;
    final double lengthVal = double.tryParse(_longitudController.text) ?? 9.0;
    final double weightVal = double.tryParse(_pesoController.text) ?? 0.56;

    final newProduct = Product(
      id: _editingProductId ?? 'prod-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _category,
      price: price,
      nominalWeight: weightVal,
      lengthMeters: lengthVal,
      specification: _gradoController.text,
      unitOfMeasure: _unitOfMeasure,
      diameterInches: diamVal,
      stock: stockVal,
      imageBase64: _imageBase64,
      pdfBase64: _pdfBase64,
      pdfName: _pdfName,
    );

    if (_editingProductId != null) {
      ProductRepository.instance.updateProduct(newProduct);
    } else {
      ProductRepository.instance.addProduct(newProduct);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Producto "${newProduct.name}" registrado con éxito!'),
        backgroundColor: const Color(0xFF005BAA),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Show beautiful success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(
                _editingProductId != null ? '¡Actualización Exitosa!' : '¡Registro Exitoso!',
                style: const TextStyle(color: Color(0xFF001B5A), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editingProductId != null
                    ? 'El producto "${newProduct.name}" se ha actualizado en la base de datos.'
                    : 'El producto "${newProduct.name}" se ha integrado correctamente a la base de datos y ya está disponible en tienda.',
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.3),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría: ${newProduct.category}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text('Grado/Norma: ${newProduct.specification}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                    const SizedBox(height: 2),
                    Text('Precio: ${newProduct.priceLabel} • Medida: ${newProduct.unitOfMeasure}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ACEPTAR', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005BAA))),
            ),
          ],
        );
      },
    );

    // Reset Form
    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _editingProductId = null;
      _nameController.clear();
      _gradoController.text = 'Grado 60';
      _diametroController.text = '3/8"';
      _longitudController.text = '9.00';
      _pesoController.text = '0.56';
      _precioController.text = '48.50';
      _category = 'Barras de Construcción';
      _unitOfMeasure = 'MT';
      _hasFicha = false;
      _hasImage = false;
      _imageBase64 = null;
      _pdfBase64 = null;
      _pdfName = null;
    });
  }

  void _cancelRegistration() {
    _clearForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Operación cancelada.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int progress = _calculateProgress();
    final bool isInfoOk = _nameController.text.trim().isNotEmpty;
    final bool isSpecsOk = _gradoController.text.isNotEmpty &&
        _diametroController.text.isNotEmpty &&
        _longitudController.text.isNotEmpty &&
        _pesoController.text.isNotEmpty;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}), // Trigger state rebuild for progress updates
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MÓDULO DE INVENTARIO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005BAA),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _editingProductId != null ? 'Edición de\nProducto' : 'Registro de Nuevo\nProducto',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions Cancel / Guardar
                  Row(
                    children: [
                      // Cancelar Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelRegistration,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text(
                            'CANCELAR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Guardar Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005BAA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            elevation: 0,
                          ),
                          child: Text(
                            _editingProductId != null ? 'ACTUALIZAR PRODUCTO' : 'REGISTRAR PRODUCTO',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Card: Información General (Blue left border)
            _buildGeneralInfoCard(),

            // 3. Card: Especificaciones Técnicas (Grey left border)
            _buildTechnicalSpecsCard(),

            // 4. Card: Documentación y Fichas
            _buildDocumentationCard(),

            // 5. Section: Imágenes del Producto
            _buildImagesSection(),

            // 6. Section: Estado de Registro (Dark Panel)
            _buildRegistrationStatusPanel(progress, isInfoOk, isSpecsOk),

            // 7. Info Box (Aviso)
            _buildAvisoBox(),

            // 8. Registered Products List
            _buildRegisteredProductsSection(),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBase64 = base64Encode(bytes);
          _hasImage = true;
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xlsx'],
        withData: true, // Esto carga los bytes en memoria automáticamente (ideal para Web o pequeños en móvil)
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        // Validar límite (1MB = 1048576 bytes) dejamos colchón
        if (bytes.length > 800000) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El archivo es muy pesado. Máximo recomendado ~800KB.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        setState(() {
          _pdfBase64 = base64Encode(bytes);
          _pdfName = result.files.single.name;
          _hasFicha = true;
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar archivo: $e");
    }
  }

  Widget _buildGeneralInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF005BAA), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Title
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF005BAA), size: 18),
              SizedBox(width: 10),
              Text(
                'Información General',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005BAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nombre del producto
          const Text(
            'NOMBRE DEL PRODUCTO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ej: Fierro Corrugado ASTM A615 G',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Categoría de inventario
          const Text(
            'CATEGORÍA DE INVENTARIO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _category = newValue);
                  }
                },
                items: <String>[
                  'Barras de Construcción',
                  'Perfiles',
                  'Planchas',
                  'Tubos y Tuberías'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Precio
          const Text(
            'PRECIO (S/)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _precioController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Ej: 48.50',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El precio es obligatorio';
              }
              if (double.tryParse(value) == null) {
                return 'Precio inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Stock
          const Text(
            'STOCK INICIAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ej: 100',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El stock es obligatorio';
              }
              if (int.tryParse(value) == null) {
                return 'Stock inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Unidad de medida
          const Text(
            'UNIDAD DE MEDIDA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildUnitButton('MT'),
              const SizedBox(width: 8),
              _buildUnitButton('KG'),
              const SizedBox(width: 8),
              _buildUnitButton('UND'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String unit) {
    final bool isSelected = _unitOfMeasure == unit;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _unitOfMeasure = unit),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF005BAA) : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? const Color(0xFF005BAA) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalSpecsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFFCBD5E1), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune, color: Color(0xFF1E293B), size: 18),
              SizedBox(width: 10),
              Text(
                'Especificaciones\nTécnicas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Grado / Norma
          _buildSpecInputField('GRADO / NORMA', _gradoController, 'Grado 60'),
          const SizedBox(height: 14),

          // Diámetro
          _buildSpecInputField('DIÁMETRO (PULG)', _diametroController, '3/8"'),
          const SizedBox(height: 14),

          // Longitud
          _buildSpecInputField('LONGITUD (M)', _longitudController, '9.00'),
          const SizedBox(height: 14),

          // Peso Nominal
          _buildSpecInputField('PESO NOMINAL (KG/M)', _pesoController, '0.56'),
        ],
      ),
    );
  }

  Widget _buildSpecInputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDocumentationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFFCBD5E1), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined, color: Color(0xFF1E293B), size: 18),
              SizedBox(width: 10),
              Text(
                'Documentación y\nFichas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dashed uploader placeholder
          GestureDetector(
            onTap: _pickPdf,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: _hasFicha ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasFicha ? Colors.green : const Color(0xFFCBD5E1),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _hasFicha ? Icons.cloud_done : Icons.cloud_upload_outlined,
                    color: _hasFicha ? Colors.green : const Color(0xFF475569),
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _hasFicha
                        ? 'Archivo cargado: $_pdfName'
                        : 'Arrastre la ficha técnica o haga clic para seleccionar archivo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _hasFicha ? Colors.green : const Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!_hasFicha)
                    const Text(
                      'Máximo ~800KB por archivo. Solo formatos .PDF, .XLSX',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'IMÁGENES DEL PRODUCTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Large Add image block
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF1F5F9),
                image: _imageBase64 != null
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(_imageBase64!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: _imageBase64 == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: Color(0xFF475569),
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SELECCIONAR IMAGEN',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _imageBase64 = null;
                                _hasImage = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // 3 smaller squares
          Row(
            children: [
              _buildSmallImageSlot(),
              const SizedBox(width: 8),
              _buildSmallImageSlot(),
              const SizedBox(width: 8),
              _buildSmallImageSlot(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallImageSlot() {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Icon(Icons.add, color: Color(0xFF94A3B8), size: 20),
      ),
    );
  }

  Widget _buildRegistrationStatusPanel(int progress, bool isInfoOk, bool isSpecsOk) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark panel matching screenshots
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ESTADO DE REGISTRO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100.0,
              backgroundColor: const Color(0xFF475569),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005BAA)),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 18),

          // Progress list items
          _buildStatusRow('Información General', isInfoOk),
          const SizedBox(height: 10),
          _buildStatusRow('Especificaciones Base', isSpecsOk),
          const SizedBox(height: 10),
          _buildStatusRow('Ficha Técnica Pendiente', _hasFicha),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isOk) {
    return Row(
      children: [
        Icon(
          isOk ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isOk ? Colors.green : const Color(0xFF64748B),
          size: 16,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isOk ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: isOk ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildAvisoBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0E1F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.help_outline,
            color: Color(0xFF005BAA),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Asegúrese de que las dimensiones ingresadas coinciden con el catálogo oficial de Aceros Arequipa S.A. para evitar discrepancias en los pedidos de clientes.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF475569),
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProduct(Product product) {
    setState(() {
      _editingProductId = product.id;
      _nameController.text = product.name;
      _gradoController.text = product.specification;
      // Convert decimal inch back to string if needed, or just use string
      if (product.diameterInches == 0.375) {
        _diametroController.text = '3/8"';
      } else if (product.diameterInches == 0.5) {
        _diametroController.text = '1/2"';
      } else if (product.diameterInches == 0.625) {
        _diametroController.text = '5/8"';
      } else if (product.diameterInches == 0.75) {
        _diametroController.text = '3/4"';
      } else if (product.diameterInches == 1.0) {
        _diametroController.text = '1"';
      } else {
        _diametroController.text = product.diameterInches.toString();
      }
      _longitudController.text = product.lengthMeters.toString();
      _pesoController.text = product.nominalWeight.toString();
      _precioController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _category = product.category;
      _unitOfMeasure = product.unitOfMeasure;
      _imageBase64 = product.imageBase64;
      _hasImage = product.imageBase64 != null;
      _pdfBase64 = product.pdfBase64;
      _pdfName = product.pdfName;
      _hasFicha = product.pdfBase64 != null;
    });
    // Scroll to top
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          content: Text('¿Estás seguro de eliminar el producto "${product.name}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ProductRepository.instance.deleteProduct(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto eliminado con éxito.'), backgroundColor: Colors.redAccent),
                );
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegisteredProductsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 32),
          const Text(
            'PRODUCTOS REGISTRADOS RECIENTEMENTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<Product>>(
            valueListenable: ProductRepository.instance.products,
            builder: (context, products, _) {
              if (products.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No hay productos registrados en este momento.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                );
              }
              // Reverse products to show the latest added first!
              final reversedProducts = products.reversed.toList();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reversedProducts.length,
                itemBuilder: (context, index) {
                  final prod = reversedProducts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.inventory_2, color: Color(0xFF005BAA)),
                      ),
                      title: Text(
                        prod.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Cat: ${prod.category} • Spec: ${prod.specification}\nPrecio: ${prod.priceLabel} • Stock: ${prod.stock} ${prod.unitOfMeasure}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF005BAA), size: 20),
                            onPressed: () => _editProduct(prod),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _confirmDelete(prod),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
