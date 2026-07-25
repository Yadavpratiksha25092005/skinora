/// Holds quiz answers temporarily while the user moves between the
/// Skin Assessment and Hair Assessment screens. Cleared after successful
/// submission to the backend.
class AssessmentDraft {
  static final AssessmentDraft _instance = AssessmentDraft._internal();
  factory AssessmentDraft() => _instance;
  AssessmentDraft._internal();

  // Skin
  String? skinFeel; // "tight_dry" | "oily_shiny" | "combination" | "normal"
  String? acneFrequency; // "rarely" | "occasionally" | "frequently"
  String? waterIntake; // "low" | "medium" | "high"

  // Hair
  String? hairType; // "straight" | "wavy" | "curly" | "coily"
  String? scalpType; // "dry" | "oily" | "normal" | "combination"
  String? hairConcern; // "Hair Fall" | "Dandruff" | "Frizzy Hair"

  Map<String, dynamic> toPayload() => {
        'skin_feel': skinFeel,
        'acne_frequency': acneFrequency,
        'water_intake': waterIntake,
        'hair_type': hairType,
        'scalp_type': scalpType,
        'hair_concern': hairConcern,
      };

  void clear() {
    skinFeel = null;
    acneFrequency = null;
    waterIntake = null;
    hairType = null;
    scalpType = null;
    hairConcern = null;
  }
}