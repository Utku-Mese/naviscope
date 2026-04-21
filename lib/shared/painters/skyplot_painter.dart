import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/models/satellite_info.dart';

class SkyplotPainter extends CustomPainter {
  final List<SatelliteInfo> satellites;
  final double elevationMask;
  final String ringLabel30;
  final String ringLabel60;
  final String cardinalNorth;
  final String cardinalEast;
  final String cardinalSouth;
  final String cardinalWest;

  SkyplotPainter({
    required this.satellites,
    this.elevationMask = 0,
    required this.ringLabel30,
    required this.ringLabel60,
    required this.cardinalNorth,
    required this.cardinalEast,
    required this.cardinalSouth,
    required this.cardinalWest,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 24;

    _drawGrid(canvas, center, radius);
    _drawCardinals(canvas, center, radius);
    _drawSatellites(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final horizonPaint = Paint()
      ..color = AppColors.borderActive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, horizonPaint);
    canvas.drawCircle(center, radius * (90 - 30) / 90, ringPaint);
    canvas.drawCircle(center, radius * (90 - 60) / 90, ringPaint);

    final crossPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 0.6;
    canvas.drawLine(
        center.translate(-radius, 0), center.translate(radius, 0), crossPaint);
    canvas.drawLine(
        center.translate(0, -radius), center.translate(0, radius), crossPaint);

    final textStyle = AppTypography.monoSmall.copyWith(
      color: AppColors.textTertiary,
      fontSize: 9,
    );
    _drawText(
        canvas,
        ringLabel30,
        center.translate(0, -(radius * (90 - 60) / 90) + 2),
        textStyle,
        Alignment.bottomCenter);
    _drawText(
        canvas,
        ringLabel60,
        center.translate(0, -(radius * (90 - 30) / 90) + 2),
        textStyle,
        Alignment.bottomCenter);

    if (elevationMask > 0) {
      final maskRadius = radius * (90 - elevationMask) / 90;
      final maskPaint = Paint()
        ..color = AppColors.warningAmber.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, maskRadius, maskPaint);
    }
  }

  void _drawCardinals(Canvas canvas, Offset center, double radius) {
    final labels = <String, double>{
      cardinalNorth: 270.0,
      cardinalEast: 0.0,
      cardinalSouth: 90.0,
      cardinalWest: 180.0,
    };
    final labelStyle = AppTypography.fieldLabel.copyWith(
      color: AppColors.textSecondary,
      fontSize: 10,
    );

    for (final entry in labels.entries) {
      final angle = entry.value * math.pi / 180;
      final pos = center.translate(
        (radius + 14) * math.sin(angle),
        -(radius + 14) * math.cos(angle),
      );
      _drawText(canvas, entry.key, pos, labelStyle, Alignment.center);
    }
  }

  void _drawSatellites(Canvas canvas, Offset center, double radius) {
    for (final sat in satellites) {
      final pos = _satellitePosition(center, radius, sat);
      final color = sat.constellation.color;
      final isUsed = sat.usedInFix;
      final isAboveMask = sat.elevationDegrees >= elevationMask;
      final dotRadius = sat.usedInFix ? 6.5 : 5.0;

      if (isUsed && isAboveMask) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, dotRadius + 5, glowPaint);
      }

      final fillPaint = Paint()
        ..color = isAboveMask
            ? (isUsed ? color : color.withValues(alpha: 0.45))
            : color.withValues(alpha: 0.2)
        ..style = isUsed ? PaintingStyle.fill : PaintingStyle.stroke;
      final strokePaint = Paint()
        ..color = isAboveMask ? color : color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      if (isUsed) {
        canvas.drawCircle(pos, dotRadius, fillPaint);
      } else {
        canvas.drawCircle(
            pos, dotRadius, Paint()..color = color.withValues(alpha: 0.12)
            ..style = PaintingStyle.fill);
        canvas.drawCircle(pos, dotRadius, strokePaint);
      }

      if (sat.cn0DbHz > 25 || isUsed) {
        final labelStyle = AppTypography.monoSmall.copyWith(
          color: isUsed ? color : color.withValues(alpha: 0.6),
          fontSize: 8,
          fontWeight: isUsed ? FontWeight.w600 : FontWeight.w400,
        );
        _drawText(
          canvas,
          sat.svid.toString(),
          pos.translate(0, -dotRadius - 5),
          labelStyle,
          Alignment.bottomCenter,
        );
      }
    }
  }

  Offset _satellitePosition(Offset center, double radius, SatelliteInfo sat) {
    final plotRadius = (90 - sat.elevationDegrees) / 90 * radius;
    final azRad = sat.azimuthDegrees * math.pi / 180;
    return center.translate(
      plotRadius * math.sin(azRad),
      -plotRadius * math.cos(azRad),
    );
  }

  void _drawText(Canvas canvas, String text, Offset position,
      TextStyle style, Alignment alignment) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      position.dx - painter.width * (alignment.x + 1) / 2,
      position.dy - painter.height * (alignment.y + 1) / 2,
    );
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(SkyplotPainter oldDelegate) {
    return oldDelegate.satellites != satellites ||
        oldDelegate.elevationMask != elevationMask ||
        oldDelegate.ringLabel30 != ringLabel30 ||
        oldDelegate.ringLabel60 != ringLabel60 ||
        oldDelegate.cardinalNorth != cardinalNorth ||
        oldDelegate.cardinalEast != cardinalEast ||
        oldDelegate.cardinalSouth != cardinalSouth ||
        oldDelegate.cardinalWest != cardinalWest;
  }
}
