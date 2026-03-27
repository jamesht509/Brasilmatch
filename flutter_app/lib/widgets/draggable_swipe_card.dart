import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme/app_colors.dart';

/// Tipo de decisão do swipe
enum SwipeDirection {
  none,
  left,   // Nope
  right,  // Like
  up,     // Super Like
}

/// Widget de card arrastável com física realista
/// 
/// Comportamento:
/// - Arrastar direita = Like (overlay verde)
/// - Arrastar esquerda = Nope (overlay vermelho)
/// - Arrastar cima = Super Like (overlay azul)
/// - Soltar no meio = volta para posição original
/// - Arrastar longe = voa para fora da tela
class DraggableSwipeCard extends StatefulWidget {
  /// Conteúdo do card (normalmente um SwipeCard widget)
  final Widget child;
  
  /// Callback quando card sai da tela
  /// direction indica se foi like/nope/super_like
  final Function(SwipeDirection direction) onSwipe;
  
  /// Controller externo (para botões de like/nope)
  final DraggableSwipeCardController? controller;
  
  const DraggableSwipeCard({
    super.key,
    required this.child,
    required this.onSwipe,
    this.controller,
  });

  @override
  State<DraggableSwipeCard> createState() => _DraggableSwipeCardState();
}

class _DraggableSwipeCardState extends State<DraggableSwipeCard>
    with SingleTickerProviderStateMixin {
  
  // Posição atual do card (offset do centro)
  Offset _position = Offset.zero;
  
  // Se está sendo arrastado
  bool _isDragging = false;
  
  // Direção atual do swipe
  SwipeDirection _swipeDirection = SwipeDirection.none;
  
  // Controller de animação (para snap back e fly away)
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  
  // Constantes de física
  static const double _threshold = 100.0; // Distância mínima para swipe
  static const double _rotationFactor = 0.3; // Quanto rotaciona por pixel
  static const double _maxRotation = 0.4; // Rotação máxima (radianos)
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _animationController.addListener(() {
      setState(() {
        _position = _animation.value;
      });
    });
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_swipeDirection != SwipeDirection.none) {
          // Card saiu da tela - notificar
          widget.onSwipe(_swipeDirection);
          
          // Reset para próximo card
          setState(() {
            _position = Offset.zero;
            _swipeDirection = SwipeDirection.none;
          });
        }
      }
    });
    
    // Conectar controller externo (se houver)
    widget.controller?._state = this;
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    widget.controller?._state = null;
    super.dispose();
  }
  
  /// Determinar direção do swipe baseado na posição
  SwipeDirection _getSwipeDirection() {
    if (_position.dx.abs() > _threshold || _position.dy.abs() > _threshold) {
      // Priorizar vertical (super like) se movimento for mais vertical
      if (_position.dy.abs() > _position.dx.abs() && _position.dy < 0) {
        return SwipeDirection.up;
      }
      
      // Horizontal: direita = like, esquerda = nope
      return _position.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    }
    
    return SwipeDirection.none;
  }
  
  /// Calcular rotação baseado na posição horizontal
  double _getRotation() {
    // Apenas rotaciona em movimentos horizontais
    if (_position.dy.abs() > _position.dx.abs()) {
      return 0; // Super like não rotaciona
    }
    
    final rotation = _position.dx * _rotationFactor / 100;
    return rotation.clamp(-_maxRotation, _maxRotation);
  }
  
  /// Calcular opacidade do overlay baseado na distância
  double _getOverlayOpacity() {
    final distance = _position.distance;
    if (distance < 20) return 0;
    
    final opacity = (distance / _threshold).clamp(0.0, 1.0);
    return opacity;
  }
  
  /// Handler de pan start (início do arraste)
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _swipeDirection = SwipeDirection.none;
    });
  }
  
  /// Handler de pan update (durante o arraste)
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _swipeDirection = _getSwipeDirection();
    });
  }
  
  /// Handler de pan end (soltou o dedo)
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    final direction = _getSwipeDirection();
    
    if (direction != SwipeDirection.none) {
      // Passou do threshold - fazer card voar
      _flyAway(direction);
    } else {
      // Não passou - voltar para posição original
      _snapBack();
    }
  }
  
  /// Animar card voltando para o centro
  void _snapBack() {
    _animation = Tween<Offset>(
      begin: _position,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _animationController.forward(from: 0);
  }
  
  /// Animar card voando para fora da tela
  void _flyAway(SwipeDirection direction) {
    final screenSize = MediaQuery.of(context).size;
    Offset target;
    
    switch (direction) {
      case SwipeDirection.left:
        target = Offset(-screenSize.width * 1.5, _position.dy);
        break;
      case SwipeDirection.right:
        target = Offset(screenSize.width * 1.5, _position.dy);
        break;
      case SwipeDirection.up:
        target = Offset(_position.dx, -screenSize.height * 1.5);
        break;
      case SwipeDirection.none:
        target = Offset.zero;
    }
    
    _swipeDirection = direction;
    
    _animation = Tween<Offset>(
      begin: _position,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward(from: 0);
  }
  
  /// Método público para swipe programático (botões)
  void swipe(SwipeDirection direction) {
    // Simular movimento
    Offset targetPosition;
    
    switch (direction) {
      case SwipeDirection.left:
        targetPosition = const Offset(-150, 0);
        break;
      case SwipeDirection.right:
        targetPosition = const Offset(150, 0);
        break;
      case SwipeDirection.up:
        targetPosition = const Offset(0, -150);
        break;
      case SwipeDirection.none:
        return;
    }
    
    setState(() {
      _position = targetPosition;
    });
    
    _flyAway(direction);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _position,
        child: Transform.rotate(
          angle: _getRotation(),
          child: Stack(
            children: [
              // Card principal
              widget.child,
              
              // Overlay de LIKE (verde, direita)
              if (_swipeDirection == SwipeDirection.right)
                _buildOverlay(
                  'LIKE',
                  AppColors.success,
                  Alignment.topLeft,
                  45,
                ),
              
              // Overlay de NOPE (vermelho, esquerda)
              if (_swipeDirection == SwipeDirection.left)
                _buildOverlay(
                  'NOPE',
                  AppColors.error,
                  Alignment.topRight,
                  -45,
                ),
              
              // Overlay de SUPER LIKE (azul, cima)
              if (_swipeDirection == SwipeDirection.up)
                _buildOverlay(
                  'SUPER\nLIKE',
                  AppColors.primary,
                  Alignment.bottomCenter,
                  0,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Construir overlay de feedback visual
  Widget _buildOverlay(
    String text,
    Color color,
    Alignment alignment,
    double rotationDegrees,
  ) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Transform.rotate(
            angle: rotationDegrees * math.pi / 180,
            child: Opacity(
              opacity: _getOverlayOpacity(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Controller para controlar swipe programaticamente (via botões)
class DraggableSwipeCardController {
  _DraggableSwipeCardState? _state;
  
  /// Fazer swipe programático
  void swipe(SwipeDirection direction) {
    _state?.swipe(direction);
  }
  
  /// Like programático
  void like() => swipe(SwipeDirection.right);
  
  /// Nope programático
  void nope() => swipe(SwipeDirection.left);
  
  /// Super like programático
  void superLike() => swipe(SwipeDirection.up);
}
