import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/environment_profile.dart';

const _kProfileKey = 'environment_profile';
const _kOnboardingDoneKey = 'onboarding_done';

enum OnboardingStatus { idle, saving, done, error }

class OnboardingViewModel extends ChangeNotifier {
  int _currentStep = 0;
  int get currentStep => _currentStep;
 
  static const totalSteps = 5;
 
  bool get canGoBack => _currentStep > 0;
  bool get isLastStep => _currentStep == totalSteps - 1;
 
  double get progress => (_currentStep + 1) / totalSteps;

  // ── Seção 1: Local ──────────────────────────────────────────────────────────
  InstallationLocation? location;
  EnvironmentType? environmentType;
  RoomSize? roomSize;
  CeilingHeight? ceilingHeight;
 
  bool get section1Valid =>
    location != null &&
    environmentType != null &&
    roomSize != null &&
    ceilingHeight != null;


  // ── Seção 2: Ventilação e Ocupação ─────────────────────────────────────────
  VentilationType? ventilation;
  OccupancyCount? occupancy;
  OccupancyDuration? duration;
 
  bool get section2Valid =>
      ventilation != null && occupancy != null && duration != null;
 
  // ── Seção 3: Fontes de Poluentes ───────────────────────────────────────────
  final Set<PollutantSource> selectedSources = {};
  PollutantFrequency? pollutantFrequency;
  PreviousIncident? previousIncident;
  String? previousIncidentDescription;
  bool _showIncidentDetail = false;
 
  bool get showIncidentDetail => _showIncidentDetail;
 
  bool get section3Valid =>
    selectedSources.isNotEmpty &&
    pollutantFrequency != null &&
    previousIncident != null;
 
  void toggleSource(PollutantSource source) {
    if (source == PollutantSource.none) {
      selectedSources.clear();
      selectedSources.add(PollutantSource.none);
    } else {
      selectedSources.remove(PollutantSource.none);
      if (selectedSources.contains(source)) {
        selectedSources.remove(source);
      } else {
        selectedSources.add(source);
      }
    }
    notifyListeners();
  }
 
  void setPreviousIncident(PreviousIncident value) {
    previousIncident = value;
    _showIncidentDetail = value == PreviousIncident.yes;
    notifyListeners();
  }
 
  // ── Seção 4: Instalação ────────────────────────────────────────────────────
  DevicePlacement? placement;
  final Set<NearbyCondition> selectedNearbyConditions = {};
 
  bool get section4Valid =>
    placement != null && selectedNearbyConditions.isNotEmpty;
 
  void toggleNearbyCondition(NearbyCondition condition) {
    if (condition == NearbyCondition.none) {
      selectedNearbyConditions.clear();
      selectedNearbyConditions.add(NearbyCondition.none);
    } else {
      selectedNearbyConditions.remove(NearbyCondition.none);
      if (selectedNearbyConditions.contains(condition)) {
        selectedNearbyConditions.remove(condition);
      } else {
        selectedNearbyConditions.add(condition);
      }
    }
    notifyListeners();
  }
 
// ── Validação por etapa ───────────────────────────────────────────────────
  bool get currentStepValid => switch (_currentStep) {
    
    0 => section1Valid,
    1 => section2Valid,
    2 => section3Valid,
    3 => section4Valid,
    4 => true,
    _ => false,
  };

   EnvironmentProfile? get previewProfile {
    if (!section1Valid || !section2Valid || !section3Valid || !section4Valid) {
      return null;
    }
    return _buildProfile();
  }
 
  EnvironmentProfile _buildProfile() => EnvironmentProfile(
    location: location!,
    environmentType: environmentType!,
    roomSize: roomSize!,
    ceilingHeight: ceilingHeight!,
    ventilation: ventilation!,
    occupancy: occupancy!,
    duration: duration!,
    pollutantSources: selectedSources.toList(),
    pollutantFrequency: pollutantFrequency!,
    previousIncident: previousIncident!,
    previousIncidentDescription: previousIncidentDescription,
    placement: placement!,
    nearbyConditions: selectedNearbyConditions.toList(),
  );
 
  // ── Alertas de posicionamento ─────────────────────────────────────────────
  List<String> get placementWarnings {
    final warnings = <String>[];
    final interferring = selectedNearbyConditions
        .where((c) => c.causesMeasurementInterference)
        .toList();
    if (interferring.isNotEmpty) {
      final labels = interferring.map((c) => c.label).join(', ');
      warnings.add(
        'O VIVA está próximo de: $labels. '
        'Isso pode afetar a precisão das medições. '
        'Considere um local mais afastado dessas correntes de ar.',
      );
    }
    return warnings;
  }
 
  // ── Navegação entre etapas ────────────────────────────────────────────────
  void nextStep() {
    if (!currentStepValid) return;
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }
 
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
 
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }
 
  // ── Persistência ──────────────────────────────────────────────────────────
  OnboardingStatus _status = OnboardingStatus.idle;
  OnboardingStatus get status => _status;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
 
  /// Salva perfil e marca onboarding como concluído
  Future<EnvironmentProfile?> saveProfile() async {
    final profile = previewProfile;
    if (profile == null) return null;
 
    _status = OnboardingStatus.saving;
    notifyListeners();
 
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kProfileKey, jsonEncode(profile.toJson()));
      await prefs.setBool(_kOnboardingDoneKey, true);
 
      // Salvar também os limiares calculados separadamente para acesso rápido
      final thresholds = profile.computedThresholds;
      await prefs.setDouble('threshold_co_warning', thresholds.coWarningPpm);
      await prefs.setDouble('threshold_co_danger', thresholds.coDangerPpm);
      await prefs.setDouble('threshold_smoke_warning', thresholds.smokeWarningPpm);
      await prefs.setDouble('threshold_smoke_danger', thresholds.smokeDangerPpm);
 
      _status = OnboardingStatus.done;
      notifyListeners();
      return profile;
    } catch (e) {
      _errorMessage = 'Erro ao salvar perfil: $e';
      _status = OnboardingStatus.error;
      notifyListeners();
      return null;
    }
  }
 
  /// Carrega perfil existente (para edição futura)
  static Future<EnvironmentProfile?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kProfileKey);
      if (raw == null) return null;
      return EnvironmentProfile.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }
 
  /// Verifica se o onboarding já foi concluído
  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDoneKey) ?? false;
  }
 
  /// Carrega limiares salvos (usados pelo DashboardViewModel)
  static Future<CustomThresholds> loadThresholds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coW = prefs.getDouble('threshold_co_warning');
      if (coW == null) return CustomThresholds.defaults;
      return CustomThresholds(
        coWarningPpm: coW,
        coDangerPpm: prefs.getDouble('threshold_co_danger') ?? 150,
        smokeWarningPpm: prefs.getDouble('threshold_smoke_warning') ?? 150,
        smokeDangerPpm: prefs.getDouble('threshold_smoke_danger') ?? 500,
      );
    } catch (_) {
      return CustomThresholds.defaults;
    }
  }
 
  // ── Setters com notificação ───────────────────────────────────────────────
 
  void setLocation(InstallationLocation v) {
    location = v;
    notifyListeners();
  }
 
  void setEnvironmentType(EnvironmentType v) {
    environmentType = v;
    notifyListeners();
  }
 
  void setRoomSize(RoomSize v) {
    roomSize = v;
    notifyListeners();
  }
 
  void setCeilingHeight(CeilingHeight v) {
    ceilingHeight = v;
    notifyListeners();
  }
 
  void setVentilation(VentilationType v) {
    ventilation = v;
    notifyListeners();
  }
 
  void setOccupancy(OccupancyCount v) {
    occupancy = v;
    notifyListeners();
  }
 
  void setDuration(OccupancyDuration v) {
    duration = v;
    notifyListeners();
  }
 
  void setPollutantFrequency(PollutantFrequency v) {
    pollutantFrequency = v;
    notifyListeners();
  }
 
  void setPlacement(DevicePlacement v) {
    placement = v;
    notifyListeners();
  }
 
  void setIncidentDescription(String v) {
    previousIncidentDescription = v.isEmpty ? null : v;
  }
}