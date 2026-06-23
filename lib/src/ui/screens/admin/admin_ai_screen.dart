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

// ─── Motor de respuestas Admin ─────────────────────────────────────────────────
class _AdminEngine {
  static String responder(String input) {
    final q = input.toLowerCase().trim();

    if (_c(q, ['stock', 'inventario', 'critico', 'reposicion'])) {
      return '📦 **Análisis de Stock — Indicadores Clave**\n\n'
          '**Productos a monitorear:**\n'
          '• Fierro 3/8": stock mínimo recomendado = 50 toneladas\n'
          '• Fierro 1/2": stock mínimo = 40 toneladas\n'
          '• Fierro 5/8": stock mínimo = 30 toneladas\n\n'
          '**KPIs de inventario:**\n'
          '• Rotación de inventario: meta > 8 veces/año\n'
          '• Días de inventario: objetivo 30–45 días\n'
          '• Fill rate: > 95%\n\n'
          '**Acción:** Revisar los productos con < 20% del stock mínimo para orden de reposición urgente.';
    }
    if (_c(q, ['venta', 'analisis', 'tendencia', 'metrica'])) {
      return '📊 **Análisis de Ventas — Métricas Clave**\n\n'
          '**Indicadores principales:**\n'
          '• Volumen mensual por SKU (toneladas)\n'
          '• Margen bruto por línea de producto\n'
          '• Ticket promedio por cliente\n'
          '• Frecuencia de recompra\n\n'
          '**Productos de mayor rotación:**\n'
          '1. Fierro corrugado 3/8" (estribos)\n'
          '2. Fierro corrugado 1/2" (uso general)\n'
          '3. Ángulos 2"×2"\n\n'
          '**Temporada alta:** Enero–Abril (inicio de obras post-verano).';
    }
    if (_c(q, ['precio', 'estrategia', 'competit', 'margen'])) {
      return '💰 **Estrategia de Precios**\n\n'
          '**Variables a considerar:**\n'
          '• Costo de materia prima (chatarra / palanquilla)\n'
          '• Costos logísticos de distribución\n'
          '• Precio de la competencia (Aceros Aza, Siderperú)\n'
          '• Volumen de pedido del cliente\n\n'
          '**Estrategia sugerida:**\n'
          '1. Precio escalonado por volumen (> 5 ton: -3%, > 10 ton: -5%)\n'
          '2. Descuento por pago anticipado: 1.5%\n'
          '3. Precio especial para constructoras registradas\n\n'
          '**Margen objetivo:** 12–18% sobre costo.';
    }
    if (_c(q, ['norma', 'ntp', 'astm', 'reglamento'])) {
      return '📚 **Normativa Técnica — Referencia Administrativa**\n\n'
          '• **NTP 341.031**: Barras corrugadas — certificación obligatoria\n'
          '• **NTP E.060**: Concreto armado — base de diseño para clientes\n'
          '• **ASTM A615 Gr.60**: Estándar internacional de referencia\n'
          '• **ISO 9001**: Sistema de calidad de producción\n\n'
          '**Para catálogo:** Todo producto debe incluir:\n'
          '1. N° de colada / lote\n'
          '2. Certificado de calidad del fabricante\n'
          '3. Código de barras/QR de trazabilidad';
    }
    if (_c(q, ['logistica', 'despacho', 'distribucion', 'ruta', 'transporte'])) {
      return '🚚 **Gestión Logística — Guía Operativa**\n\n'
          '**Plantas de despacho:**\n'
          '• Planta Lurín (Lima): cobertura Lima Metropolitana\n'
          '• Planta Pisco (Ica): cobertura sur del país\n\n'
          '**Tiempos de entrega:**\n'
          '• Lima: 24–48 horas\n'
          '• Provincia: 48–96 horas\n\n'
          '**Capacidad de flota:**\n'
          '• Camión plataforma: hasta 30 toneladas\n'
          '• Camioneta: hasta 2 toneladas (entregas urgentes)\n\n'
          '**Optimización:** Consolidar pedidos de la misma zona para reducir costo/ton.';
    }
    if (_c(q, ['kpi', 'indicador', 'rendimiento', 'desempeno'])) {
      return '📈 **KPIs Operacionales — Dashboard**\n\n'
          '**Ventas:**\n'
          '• Ventas mensuales (S/.)\n'
          '• Unidades vendidas (ton)\n'
          '• N° de pedidos procesados\n\n'
          '**Operaciones:**\n'
          '• Tiempo promedio de despacho\n'
          '• % pedidos entregados a tiempo\n'
          '• Tasa de reclamaciones\n\n'
          '**Financiero:**\n'
          '• Días de cobro (DSO)\n'
          '• Rotación de cuentas por cobrar\n'
          '• Margen neto por línea de producto';
    }
    if (_c(q, ['producto', 'registrar', 'agregar', 'catalogo', 'nuevo'])) {
      return '🏷️ **Registro de Nuevos Productos**\n\n'
          '**Información requerida:**\n'
          '1. Nombre comercial del producto\n'
          '2. Categoría (fierro, ángulo, plancha, tubo)\n'
          '3. Especificaciones técnicas (medida, peso, norma)\n'
          '4. Precio de venta (S/.)\n'
          '5. Stock inicial disponible\n'
          '6. URL de imagen del producto\n\n'
          '**Proceso:** Ve a la pantalla "Tienda" → botón "AÑADIR PRODUCTO" y completa el formulario. El producto aparecerá inmediatamente en el catálogo del cliente.';
    }
    if (_c(q, ['hola', 'buenos', 'buen dia', 'ayuda'])) {
      return '👋 ¡Bienvenido, Administrador!\n\n'
          'Soy tu asistente de gestión. Puedo ayudarte con:\n'
          '• 📦 Análisis de stock e inventario\n'
          '• 📊 Métricas y tendencias de ventas\n'
          '• 💰 Estrategias de precios\n'
          '• 📚 Normativa técnica (NTP, ASTM)\n'
          '• 🚚 Gestión logística y despacho\n'
          '• 📈 KPIs operacionales\n'
          '• 🏷️ Registro de productos en catálogo\n\n'
          '¿En qué te apoyo hoy?';
    }
    if (_c(q, ['gracias', 'ok', 'perfecto', 'listo'])) {
      return '¡Con gusto, Administrador! 💼 Recuerda revisar los indicadores del dashboard diariamente para mantener la operación optimizada.\n\n¿Hay algo más en lo que pueda asistirte?';
    }

    return '🤔 No encontré información específica para esa consulta.\n\n'
        'Puedo ayudarte con:\n'
        '• Revisar stock crítico\n'
        '• Análisis de ventas\n'
        '• Estrategia de precios\n'
        '• Normas técnicas NTP\n'
        '• KPIs operacionales\n'
        '• Registro de productos';
  }

  static bool _c(String q, List<String> kw) => kw.any((k) => q.contains(k));
}

// ─── Pantalla ─────────────────────────────────────────────────────────────────
class AdminAiScreen extends StatefulWidget {
  const AdminAiScreen({super.key});
  @override
  State<AdminAiScreen> createState() => _AdminAiScreenState();
}

class _AdminAiScreenState extends State<AdminAiScreen> with TickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _dotAnim;

  static const _quickActions = [
    {'icon': Icons.inventory_2_outlined, 'label': 'Revisar stock crítico',
      'query': 'Analizar stock crítico e inventario'},
    {'icon': Icons.bar_chart_outlined, 'label': 'Análisis de ventas',
      'query': 'Análisis de tendencias y métricas de ventas'},
    {'icon': Icons.engineering_outlined, 'label': 'Normas técnicas NTP',
      'query': 'Información sobre normas técnicas NTP y ASTM'},
    {'icon': Icons.price_change_outlined, 'label': 'Estrategia de precios',
      'query': 'Estrategia de precios competitiva'},
  ];

  @override
  void initState() {
    super.initState();
    _dotAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _addAi('¡Bienvenido, Administrador! Soy tu asistente de gestión de Aceros Arequipa. ¿En qué te apoyo hoy?'));
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
    await Future.delayed(Duration(milliseconds: 700 + Random().nextInt(500)));
    final reply = _AdminEngine.responder(text.trim());
    _addAi(reply);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final showQuick = _messages.length == 1 && !_isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _buildMessages()),
        if (showQuick) _buildQuickActions(),
        _buildInput(),
      ]),
    );
  }

  Widget _buildHeader() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF001B5A), Color(0xFF0A3D91)])),
    padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
    child: Row(children: [
      Container(width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
          child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 24)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Asistente de Gestión AI',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        Row(children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('MODO ADMINISTRADOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.85), letterSpacing: 0.5)),
        ]),
      ])),
      IconButton(
        icon: Icon(Icons.refresh_rounded, color: Colors.white.withValues(alpha: 0.8), size: 22),
        onPressed: () {
          setState(() => _messages.clear());
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              _addAi('¡Nueva sesión iniciada! ¿En qué te apoyo hoy, Administrador?'));
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
      Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8, bottom: 4),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF001B5A), Color(0xFF0A3D91)]),
              borderRadius: BorderRadius.circular(9)),
          child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 17)),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Text(m.text, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5))),
        const SizedBox(height: 4),
        Text('ASISTENTE ADMIN • ${_fmt(m.time)}',
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 0.3)),
      ])),
    ]),
  );

  Widget _buildUserBubble(_ChatMessage m) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF001B5A), Color(0xFF0A3D91)]),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4))),
          child: Text(m.text, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.45))),
        const SizedBox(height: 4),
        Text('ADMIN • ${_fmt(m.time)}',
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 0.3)),
      ])),
    ]),
  );

  Widget _buildTyping() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8, bottom: 4),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF001B5A), Color(0xFF0A3D91)]),
              borderRadius: BorderRadius.circular(9)),
          child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 17)),
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16),
              bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: AnimatedBuilder(
          animation: _dotAnim,
          builder: (ctx, child) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
            final t = ((_dotAnim.value * 3) - i).clamp(0.0, 1.0);
            final o = (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2)).clamp(0.3, 1.0);
            return Container(width: 7, height: 7, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(color: Color.fromRGBO(10, 61, 145, o), shape: BoxShape.circle));
          })),
        ),
      ),
    ]),
  );

  Widget _buildQuickActions() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Acciones rápidas de gestión:',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.3)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: _quickActions.map((a) => GestureDetector(
        onTap: () => _send(a['query'] as String),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(a['icon'] as IconData, size: 15, color: const Color(0xFF001B5A)),
            const SizedBox(width: 6),
            Text(a['label'] as String,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
          ]),
        ),
      )).toList()),
    ]),
  );

  Widget _buildInput() => Container(
    decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))]),
    padding: EdgeInsets.only(left: 16, right: 12, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 16),
    child: Row(children: [
      Expanded(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: TextField(controller: _inputController, maxLines: null,
          textInputAction: TextInputAction.send, onSubmitted: _send,
          decoration: const InputDecoration(hintText: 'Consulta técnica o de gestión...',
              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12), isDense: true),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
      )),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => _send(_inputController.text),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: _isLoading ? null : const LinearGradient(colors: [Color(0xFF001B5A), Color(0xFF0A3D91)]),
            color: _isLoading ? const Color(0xFF94A3B8) : null,
            borderRadius: BorderRadius.circular(22)),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
      ),
    ]),
  );

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
