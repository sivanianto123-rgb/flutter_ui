import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class StarExplosionEffect extends ParticleSystemComponent {
  StarExplosionEffect(Vector2 position)
      : super(
          position: position,
          particle: Particle.generate(
            count: 40,
            lifespan: 1.5,
            generator: (i) {
              final random = Random();
              return AcceleratedParticle(
                acceleration: Vector2(0, 400), // Gravity
                speed: Vector2(
                  (random.nextDouble() - 0.5) * 800,
                  (random.nextDouble() - 0.5) * 800,
                ),
                position: Vector2.zero(),
                child: RotatingParticle(
                  to: random.nextDouble() * pi * 2,
                  child: ComputedParticle(
                    renderer: (canvas, particle) {
                      final paint = Paint()
                        ..color = Colors.amber.withOpacity(
                            1.0 - (particle.progress).clamp(0.0, 1.0));
                      // Simple star approximating a circle for performance 
                      // or use drawPath for an actual star.
                      canvas.drawCircle(Offset.zero, 15, paint);
                      
                      // Inner glow
                      final inner = Paint()
                        ..color = Colors.white.withOpacity(
                            1.0 - (particle.progress).clamp(0.0, 1.0));
                      canvas.drawCircle(Offset.zero, 6, inner);
                    },
                  ),
                ),
              );
            },
          ),
        );
}
