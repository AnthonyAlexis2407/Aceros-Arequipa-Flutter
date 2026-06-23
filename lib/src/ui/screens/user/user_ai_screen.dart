import 'dart:math';
import 'package:flutter/material.dart';

// ─── Modelo ───────────────────────────────────────────────────────────────────
enum _Sender { user, ai }

class _ChatMessage {
  final String text;
  final _Sender sender;
  final DateTime time;
  const _ChatMessage({required this.text, required this.sender, required this.time});
}

// ─── Motor de respuestas ──────────────────────────────────────────────────────
class _AsesorEngine {
  static String responder(String input) {
    final q = input.toLowerCase().trim();

    // Calculos de fierro/columnas
    if (_c(q, ['columna', 'fierro', 'corrugado', 'calcul'])) {
      return '📐 **Cálculo de Fierro para Columnas**\n\n'
          'Para una columna de 30×30 cm (norma NTP 341.031 / ASTM A615 Grado 60):\n\n'
          '• **Fierro longitudinal:** 4 varillas de 5/8" (16mm)\n'
          '• **Estribos:** 3/8" @ 20cm zona central, @ 10cm en zonas de confinamiento\n'
          '• **Longitud de anclaje:** mínimo 60 cm en zapata\n'
          '• **Recubrimiento:** 4 cm mínimo\n\n'
          '¿Necesitas calcular para otra dimensión de columna?';
    }
    if (_c(q, ['viga', 'fierro viga'])) {
      return '📐 **Cálculo de Fierro para Vigas**\n\n'
          'Viga típica 25×50 cm (NTP 341.031):\n\n'
          '• **Acero inferior (tracción):** 3 varillas de 5/8"\n'
          '• **Acero superior (compresión):** 2 varillas de 1/2"\n'
          '• **Estribos:** 3/8" @ 15cm zona central, @ 8cm en extremos\n'
          '• **Resistencia:** fy = 4200 kg/cm²\n\n'
          'Proporciona la luz de la viga para un cálculo más preciso.';
    }
    if (_c(q, ['zapata', 'cimiento', 'fundacion'])) {
      return '📐 **Cálculo de Zapata**\n\n'
          'Zapata aislada 1.50×1.50 m (para columna 30×30):\n\n'
          '• **Malla inferior:** fierro 1/2" @ 20cm ambos sentidos\n'
          '• **Altura:** 50 cm mínimo\n'
          '• **Recubrimiento:** 7.5 cm (contacto con suelo)\n'
          '• **Cantidad aproximada:** 18 varillas de 6m (1/2")\n\n'
          'Capacidad portante del suelo requerida: 1.0 kg/cm² mínimo.';
    }
    if (_c(q, ['losa', 'aligerada'])) {
      return '📐 **Cálculo de Losa Aligerada**\n\n'
          'Losa aligerada h=20cm, luz 4m (NTP E.060):\n\n'
          '• **Fierro longitudinal:** 3/8" @ 25cm\n'
          '• **Acero de temperatura:** 1/4" @ 25cm perpendicular\n'
          '• **Viguetas:** cada 40cm\n'
          '• **Consumo aprox.:** 8 kg/m² de acero corrugado\n\n'
          '¿Cuántos m² tiene tu losa para calcular el total?';
    }

    // Productos / fichas técnicas
    if (_c(q, ['ficha', 'especificacion', 'dato tecnico'])) {
      return '📋 **Ficha Técnica — Fierro Corrugado Grado 60**\n\n'
          '| Propiedad | Valor |\n'
          '|-----------|-------|\n'
          '| Norma | NTP 341.031 / ASTM A615 |\n'
          '| Grado | 60 (fy = 4200 kg/cm²) |\n'
          '| Elongación mín. | 7% |\n'
          '| Límite de fluencia | 4200 kg/cm² |\n'
          '| Resist. a tracción | 6300 kg/cm² |\n\n'
          'Diámetros disponibles: 6mm, 8mm, 3/8", 12mm, 1/2", 5/8", 3/4", 1"';
    }
    if (_c(q, ['angulo', 'perfil l', 'angular'])) {
      return '📋 **Ángulos de Acero — Aceros Arequipa**\n\n'
          '• L 1"×1"×1/8" — peso: 1.22 kg/m\n'
          '• L 1½"×1½"×3/16" — peso: 2.14 kg/m\n'
          '• L 2"×2"×3/16" — peso: 2.90 kg/m\n'
          '• L 2"×2"×1/4" — peso: 3.80 kg/m\n'
          '• L 3"×3"×1/4" — peso: 5.72 kg/m\n\n'
          'Longitud estándar: 6 metros. Norma: ASTM A36.';
    }
    if (_c(q, ['plancha', 'placa', 'lamina'])) {
      return '📋 **Planchas de Acero — Aceros Arequipa**\n\n'
          '• Plancha LAF (laminada en frío) — espesor 0.9 a 3mm\n'
          '• Plancha LAC (laminada en caliente) — espesor 3 a 25mm\n'
          '• Plancha estriada — 3/16" a 3/8"\n\n'
          'Medidas estándar: 1.20×2.40m, 1.50×3.00m, 1.22×6.00m\n'
          'Norma: ASTM A36 (fy = 2500 kg/cm²)';
    }
    if (_c(q, ['tubo', 'tuberia', 'perfil hueco'])) {
      return '📋 **Tubos Estructurales — Aceros Arequipa**\n\n'
          '• Tubo cuadrado: 1"×1", 2"×2", 3"×3", 4"×4"\n'
          '• Tubo rectangular: 2"×4", 3"×6", 4"×8"\n'
          '• Tubo redondo: ¾", 1", 1½", 2", 3"\n\n'
          'Espesores: 1.5mm, 2mm, 3mm. Longitud: 6m. Norma: ASTM A500.';
    }

    // Precios
    if (_c(q, ['precio', 'costo', 'cuanto', 'valor', 'tarifa'])) {
      return '💰 **Precios Referenciales (S/.)**\n\n'
          '• Fierro 3/8" (kg): ~S/. 3.20 – 3.60\n'
          '• Fierro 1/2" (kg): ~S/. 3.15 – 3.55\n'
          '• Fierro 5/8" (kg): ~S/. 3.10 – 3.50\n'
          '• Plancha LAC 1/4" (kg): ~S/. 3.80 – 4.20\n'
          '• Ángulo 2"×2"×3/16" (m): ~S/. 15.00\n\n'
          '⚠️ Precios varían según volumen y fecha. Verifica en la sección Tienda.';
    }

    // Despacho / logística
    if (_c(q, ['despacho', 'envio', 'entrega', 'pedido', 'seguimiento'])) {
      return '🚚 **Información de Despacho**\n\n'
          '**Modalidades disponibles:**\n'
          '• Despacho a obra: entrega en 48–72 horas hábiles\n'
          '• Recojo en planta: Lurín o Pisco (mismo día)\n\n'
          '**Requisitos logísticos:**\n'
          '• Carga mayor a 5 toneladas: requiere grúa en obra\n'
          '• Acceso mínimo para camión: 3.5m ancho\n\n'
          '**Para seguimiento:** Ingresa tu número de pedido en el módulo Carrito → Mis Pedidos.';
    }

    // NTP / normas
    if (_c(q, ['norma', 'ntp', 'astm', 'reglamento', 'aci', 'e.060'])) {
      return '📚 **Normas Técnicas Aplicables**\n\n'
          '• **NTP 341.031**: Barras de acero corrugado para concreto armado\n'
          '• **NTP E.060**: Reglamento Nacional de Edificaciones — Concreto Armado\n'
          '• **ASTM A615**: Barras de acero deformadas y lisas\n'
          '• **ACI 318**: Building Code para concreto estructural\n'
          '• **ISO 6935**: Acero para el refuerzo del hormigón\n\n'
          'Todos los productos Aceros Arequipa cumplen NTP 341.031 y ASTM A615.';
    }

    // Saludo / presentacion
    if (_c(q, ['hola', 'buenas', 'buen dia', 'buenas tardes', 'ayuda', 'inicio'])) {
      return '👋 ¡Hola! Soy el Asesor Técnico de Aceros Arequipa.\n\n'
          'Puedo ayudarte con:\n'
          '• 📐 Cálculos de fierro (columnas, vigas, zapatas, losas)\n'
          '• 📋 Fichas técnicas de productos\n'
          '• 💰 Precios referenciales\n'
          '• 🚚 Información de despacho y logística\n'
          '• 📚 Normas técnicas (NTP, ASTM, ACI)\n\n'
          '¿En qué te puedo ayudar hoy?';
    }

    // Gracias
    if (_c(q, ['gracias', 'thank', 'perfecto', 'listo', 'ok'])) {
      return '¡Con gusto! 😊 Si tienes más consultas técnicas o necesitas algún cálculo adicional, estoy aquí para ayudarte.\n\n'
          '¿Hay algo más en lo que pueda asistirte?';
    }

    // Default inteligente
    final tips = [
      'Puedes preguntarme sobre:\n• Cálculo de fierro para columnas o vigas\n• Fichas técnicas de productos\n• Normas NTP y ASTM\n• Precios y despacho',
      'Intenta preguntarme: "¿Cuánto fierro necesito para una columna de 25×25?" o "¿Cuál es la ficha técnica del fierro 5/8?"',
      'Estoy especializado en productos de acero para construcción. Pregúntame sobre especificaciones, cálculos o logística.',
    ];
    final idx = Random().nextInt(tips.length);
    return '🤔 No encontré información específica para esa consulta.\n\n${tips[idx]}';
  }

  static bool _c(String q, List<String> kw) => kw.any((k) => q.contains(k));
}

// ─── Pantalla ─────────────────────────────────────────────────────────────────
class UserAiScreen extends StatefulWidget {
  const UserAiScreen({super.key});
  @override
  State<UserAiScreen> createState() => _UserAiScreenState();
}

class _UserAiScreenState extends State<UserAiScreen> with TickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _dotAnim;

  static const _quickActions = [
    {'icon': Icons.calculate_outlined, 'label': 'Calcular fierro para columnas',
      'query': 'Calcular fierro corrugado para columna 30x30 cm'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Seguimiento de despacho',
      'query': '¿Cómo hago seguimiento de mi pedido de despacho?'},
    {'icon': Icons.description_outlined, 'label': 'Ficha técnica',
      'query': 'Dame la ficha técnica del fierro corrugado Grado 60'},
  ];

  @override
  void initState() {
    super.initState();
    _dotAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _addAi('¡Hola! Soy tu asesor técnico de Aceros Arequipa. ¿En qué obra te ayudo hoy?'));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _dotAnim.dispose();
    super.dispose();
  }

  void _addAi(String text) {
    setState(() => _messages.add(_ChatMessage(text: text, sender: _Sender.ai, time: DateTime.now())));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _inputController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), sender: _Sender.user, time: DateTime.now()));
      _isLoading = true;
    });
    _scrollToBottom();
    // Simular tiempo de respuesta
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(600)));
    final reply = _AsesorEngine.responder(text.trim());
    _addAi(reply);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final showQuick = _messages.length == 1 && !_isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessages()),
          if (showQuick) _buildQuickActions(),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
    child: Row(children: [
      Container(width: 42, height: 42,
          decoration: BoxDecoration(color: const Color(0xFF001B5A), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Asesor Técnico AI',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        Row(children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          const Text('EN LÍNEA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
              color: Color(0xFF22C55E), letterSpacing: 0.5)),
        ]),
      ])),
      IconButton(
        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 22),
        onPressed: () {
          setState(() => _messages.clear());
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              _addAi('¡Hola! Soy tu asesor técnico de Aceros Arequipa. ¿En qué obra te ayudo hoy?'));
        },
      ),
    ]),
  );

  Widget _buildMessages() => ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    itemCount: _messages.length + (_isLoading ? 1 : 0),
    itemBuilder: (ctx, i) {
      if (i == _messages.length) return _buildTyping();
      final m = _messages[i];
      return m.sender == _Sender.ai ? _buildAiBubble(m) : _buildUserBubble(m);
    },
  );

  Widget _buildAiBubble(_ChatMessage m) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(width: 30, height: 30, margin: const EdgeInsets.only(right: 8, bottom: 4),
          decoration: BoxDecoration(color: const Color(0xFF001B5A), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16)),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Text(m.text, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.45)),
        ),
        const SizedBox(height: 4),
        Text('ASESOR ACEROS • ${_fmt(m.time)}',
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 0.3)),
      ])),
    ]),
  );

  Widget _buildUserBubble(_ChatMessage m) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(color: Color(0xFF001B5A),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4)),
          ),
          child: Text(m.text, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.45)),
        ),
        const SizedBox(height: 4),
        Text('TÚ • ${_fmt(m.time)}',
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 0.3)),
      ])),
    ]),
  );

  Widget _buildTyping() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(width: 30, height: 30, margin: const EdgeInsets.only(right: 8, bottom: 4),
          decoration: BoxDecoration(color: const Color(0xFF001B5A), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16),
              bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: AnimatedBuilder(
          animation: _dotAnim,
          builder: (ctx, child) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
            final t = ((_dotAnim.value * 3) - i).clamp(0.0, 1.0);
            final o = (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2)).clamp(0.3, 1.0);
            return Container(width: 7, height: 7, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(color: Color.fromRGBO(0, 27, 90, o), shape: BoxShape.circle));
          })),
        ),
      ),
    ]),
  );

  Widget _buildQuickActions() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Herramientas disponibles:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      const SizedBox(height: 10),
      ..._quickActions.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => _send(a['query'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(children: [
              Icon(a['icon'] as IconData, size: 18, color: const Color(0xFF001B5A)),
              const SizedBox(width: 10),
              Expanded(child: Text(a['label'] as String,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)))),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
            ]),
          ),
        ),
      )),
    ]),
  );

  Widget _buildInput() => Container(
    color: Colors.white,
    padding: EdgeInsets.only(left: 16, right: 12, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 16),
    child: Row(children: [
      Expanded(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          const Icon(Icons.mic_none_outlined, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _inputController, maxLines: null,
            textInputAction: TextInputAction.send, onSubmitted: _send,
            decoration: const InputDecoration(hintText: 'Escribe tu consulta técnica...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12), isDense: true),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          )),
        ]),
      )),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => _send(_inputController.text),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 44, height: 44,
          decoration: BoxDecoration(
            color: _isLoading ? const Color(0xFF94A3B8) : const Color(0xFF001B5A),
            borderRadius: BorderRadius.circular(22)),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
      ),
    ]),
  );

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
