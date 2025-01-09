import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdSpringState {
  final double position;
  final double force;
  final double velocity;
  final bool isMoving;
  LdSpringState({
    required this.position,
    required this.force,
    required this.velocity,
    required this.isMoving,
  });
}

class LdSpring extends StatefulWidget {
  // Constants
  final double mass;
  final double springConstant;
  final double dampingCoefficient;
  final double position;
  final double initialPosition;
  final bool paused;

  final void Function(BuildContext context, LdSpringState state)?
      onAnimationEnd;

  final Widget Function(
    BuildContext context,
    LdSpringState state,
  ) builder;

  const LdSpring({
    super.key,
    this.mass = 5,
    this.springConstant = 10,
    this.dampingCoefficient = 9,
    required this.builder,
    this.paused = false,
    this.position = 1.0,
    this.initialPosition = 1.0,
    this.onAnimationEnd,
  });

  @override
  State<LdSpring> createState() => _LdSpringState();
}

class _Spring {
  // Time step for the simulation
  double timeStep = 0.1 / timeDilation;

  double springConstant;
  double dampingCoefficient;
  double mass;
  double targetPosition;

  _Spring({
    this.springConstant = 10,
    this.dampingCoefficient = 9,
    this.position = 1.0,
    this.targetPosition = 1.0,
    this.mass = 5,
  });

  bool get active => force.abs() > 0.001 || velocity.abs() > 0.001;

  // State variables
  double position = 1.0;
  double velocity = 0.0;
  double acceleration = 0.0;

  double get springForce => -springConstant * (position - targetPosition);

  double get dampingForce => -dampingCoefficient * velocity;

  double get force => springForce + dampingForce;

  void update() {
    // Update acceleration
    acceleration = force / mass;

    // Update velocity and position using Euler's method
    velocity += acceleration * timeStep;
    position += velocity * timeStep;

    if (!active) {
      position = targetPosition;
    }
  }
}

class _LdSpringState extends State<LdSpring>
    with SingleTickerProviderStateMixin {
  late final _Spring _spring = _Spring(
    springConstant: widget.springConstant,
    dampingCoefficient: widget.dampingCoefficient,
    mass: widget.mass,
    position: widget.initialPosition,
    targetPosition: widget.position,
  );

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    _spring.targetPosition = widget.position;
    _spring.mass = widget.mass;
    _spring.springConstant = widget.springConstant;
    _spring.dampingCoefficient = widget.dampingCoefficient;

    if (oldWidget.position != widget.position) {
      if (ldDisableAnimations) {
        Future.delayed(Duration.zero, () {
          if (widget.onAnimationEnd != null && mounted) {
            widget.onAnimationEnd!(
              context,
              LdSpringState(
                position: widget.position,
                force: 0,
                velocity: 0,
                isMoving: false,
              ),
            );
          }
        });
        return;
      } else {
        if (!_ticker!.isTicking) {
          _ticker!.start();
        }
      }
    }
  }

  Ticker? _ticker;

  void update() {
    if (widget.paused) {
      return;
    }
    _spring.update();
    if (!_spring.active) {
      if (widget.onAnimationEnd != null) {
        widget.onAnimationEnd!(
          context,
          LdSpringState(
            position: _spring.position,
            force: _spring.force,
            velocity: _spring.velocity,
            isMoving: false,
          ),
        );
      }
      _ticker!.stop();
    }
  }

  @override
  void initState() {
    _ticker ??= createTicker((elapsed) {
      update();

      setState(() {});
    });

    if (_ticker?.isTicking == false) {
      _ticker?.start();
    }

    super.initState();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ldDisableAnimations) {
      return widget.builder(
        context,
        LdSpringState(
          position: widget.position,
          force: 0,
          velocity: 0,
          isMoving: false,
        ),
      );
    }

    return widget.builder(
      context,
      LdSpringState(
        position: _spring.position,
        force: _spring.force,
        velocity: _spring.velocity,
        isMoving: _ticker?.isActive ?? false,
      ),
    );
  }
}

class LdChainedSprings extends StatefulWidget {
  final int count;
  final double mass;
  final double springConstant;
  final double dampingCoefficient;
  final double initialPosition;
  final double targetPosition;
  final bool reversed;

  final Widget Function(
    BuildContext context,
    List<LdSpringState> states,
  ) builder;

  const LdChainedSprings({
    super.key,
    this.count = 5,
    this.mass = 5,
    this.springConstant = 10,
    this.dampingCoefficient = 9,
    required this.builder,
    this.reversed = false,
    this.initialPosition = 1.0,
    this.targetPosition = 1.0,
  });

  @override
  State<LdChainedSprings> createState() => _LdChainedSpringsState();
}

class _LdChainedSpringsState extends State<LdChainedSprings>
    with SingleTickerProviderStateMixin {
  late final List<_Spring> _springs = [];

  Ticker? _ticker;

  @override
  void initState() {
    _createSprings();
    _ticker ??= createTicker((elapsed) {
      update();

      setState(() {});
    });

    if (_ticker?.isTicking != true) {
      _ticker?.start();
    }

    super.initState();
  }

  void _createSprings() {
    if (_springs.length == widget.count) {
      return;
    }

    if (_springs.length > widget.count) {
      _springs.removeRange(widget.count, _springs.length);
    }

    if (_springs.length < widget.count) {
      _springs.addAll(List.generate(widget.count - _springs.length, (index) {
        return _Spring(
          springConstant: widget.springConstant,
          dampingCoefficient: widget.dampingCoefficient,
          mass: widget.mass,
          position: widget.initialPosition,
          targetPosition: widget.targetPosition,
        );
      }));
    }
  }

  @override
  void didUpdateWidget(covariant LdChainedSprings oldWidget) {
    if (oldWidget.count != widget.count) {
      _createSprings();
    }

    if (_springs.isNotEmpty) {
      if (!widget.reversed) {
        _springs[0].targetPosition = widget.targetPosition;
      } else {
        _springs[_springs.length - 1].targetPosition = widget.targetPosition;
      }
    }

    for (var i = 0; i < _springs.length; i++) {
      _springs[i].mass = widget.mass;
      _springs[i].springConstant = widget.springConstant;
      _springs[i].dampingCoefficient = widget.dampingCoefficient;
    }

    if (oldWidget.targetPosition != widget.targetPosition) {
      if (!_ticker!.isTicking) {
        _ticker!.start();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void update() {
    if (_springs.isEmpty) {
      return;
    }

    if (!widget.reversed) {
      for (var i = 0; i < _springs.length; i++) {
        _springs[i].update();
        if (i < _springs.length - 1) {
          _springs[i + 1].targetPosition = _springs[i].position;
        }
      }
    } else {
      for (var i = _springs.length - 1; i >= 0; i--) {
        _springs[i].update();
        if (i > 0) {
          _springs[i - 1].targetPosition = _springs[i].position;
        }
      }
    }

    if (!_springs.any((spring) => spring.active)) {
      _ticker?.stop();
    }

    setState(() {});
  }

  @override
  dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ldDisableAnimations) {
      return widget.builder(
        context,
        _springs.map((spring) {
          return LdSpringState(
            position: widget.targetPosition,
            force: 0,
            velocity: 0,
            isMoving: false,
          );
        }).toList(),
      );
    }

    return widget.builder(
      context,
      _springs.map((spring) {
        return LdSpringState(
          position: spring.position,
          force: spring.force,
          velocity: spring.velocity,
          isMoving: _ticker?.isActive ?? false,
        );
      }).toList(),
    );
  }
}
