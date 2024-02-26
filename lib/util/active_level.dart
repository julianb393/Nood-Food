///  Sedentary (little or no exercise): AMR = BMR x 1.2
///  Lightly active (exercise 1–3 days/week): AMR = BMR x 1.375
///  Moderately active (exercise 3–5 days/week): AMR = BMR x 1.55
///  Active (exercise 6–7 days/week): AMR = BMR x 1.725
///  Very active (hard exercise 6–7 days/week): AMR = BMR x 1.9
enum ActiveLevel {
  sedentary(1.2, 'None'),
  lightlyActive(1.375, 'Light'),
  moderatelyActive(1.55, 'Moderate'),
  active(1.725, 'A lot'),
  veryActive(1.9, 'Very');

  const ActiveLevel(this.amrMultiplier, this.title);
  final double amrMultiplier;
  final String title;
}
