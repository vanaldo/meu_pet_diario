// lib/models/pet_model.dart
import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String nome;
  final String raca;
  final int idade;
  final double peso;
  final IconData icone;

  Pet({
    required this.id,
    required this.nome,
    required this.raca,
    required this.idade,
    required this.peso,
    this.icone = Icons.pets,
  });
}