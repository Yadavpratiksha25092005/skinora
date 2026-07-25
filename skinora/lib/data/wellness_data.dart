import 'package:flutter/material.dart';
import '../models/wellness_topic.dart';

/// Static educational content for the Women's Wellness module.
/// General information only — not medical advice.
const List<WellnessTopic> wellnessTopics = [
  WellnessTopic(
    title: 'What is PCOS?',
    category: 'PCOS',
    summary: 'A common hormonal condition affecting how the ovaries work.',
    icon: Icons.info_outline_rounded,
    content: '''
Polycystic Ovary Syndrome (PCOS) is a hormonal condition that affects how the ovaries function. It's one of the most common hormonal disorders among women of reproductive age, and it can affect periods, fertility, skin, and metabolism.

Common signs include irregular or missed periods, excess facial or body hair, acne, weight gain (especially around the abdomen), and thinning hair on the scalp. Not everyone experiences all symptoms, and severity varies widely from person to person.

The exact cause isn't fully understood, but insulin resistance, genetics, and low-grade inflammation are believed to play a role. PCOS is manageable with the right combination of lifestyle changes and, when needed, medical treatment.

This is general educational information, not a diagnosis. If you suspect you have PCOS, please consult a gynecologist or endocrinologist for proper testing and personalized care.''',
  ),
  WellnessTopic(
    title: 'What is PCOD?',
    category: 'PCOD',
    summary: 'A related but distinct condition — here\'s how it differs from PCOS.',
    icon: Icons.help_outline_rounded,
    content: '''
Polycystic Ovarian Disease (PCOD) is a condition where the ovaries produce immature or partially mature eggs, which can accumulate and form cysts. It's often used interchangeably with PCOS, but they aren't exactly the same.

PCOD is generally considered less severe and more common — it's largely linked to lifestyle and hormonal imbalance, and often improves significantly with diet and exercise changes. PCOS, on the other hand, is a broader metabolic and endocrine disorder that can have a stronger genetic and insulin-resistance component, and may need more active medical management.

Both share overlapping symptoms: irregular periods, weight gain, acne, and excess hair growth. The key difference is that PCOD rarely leads to major fertility complications, while unmanaged PCOS more often does.

Since the terms are sometimes used loosely even by clinicians, the most reliable way to know which you have — and what it means for you — is a proper evaluation by a doctor.''',
  ),
  WellnessTopic(
    title: 'Signs of Hormonal Imbalance',
    category: 'Hormonal Health',
    summary: 'Subtle signals your body sends when hormones are out of sync.',
    icon: Icons.balance_rounded,
    content: '''
Hormones influence far more than your cycle — they affect mood, skin, sleep, weight, and energy. When they're out of balance, your body often sends early warning signs.

Watch for: irregular or unusually heavy/light periods, persistent fatigue even after resting, sudden weight changes without diet shifts, acne along the jawline or chin, hair thinning or excess hair growth, mood swings or anxiety that feel disproportionate, and trouble sleeping despite being tired.

Occasional symptoms are normal — bodies fluctuate. But when several of these show up together and persist for a few months, it's worth paying attention to.

These signs alone don't confirm a specific condition. If they're recurring or affecting your daily life, a doctor can run simple blood tests to check hormone levels and guide you toward the right next step.''',
  ),
  WellnessTopic(
    title: 'PCOS-Friendly Diet Tips',
    category: 'Diet',
    summary: 'Simple food choices that support hormone and insulin balance.',
    icon: Icons.restaurant_rounded,
    relevantPhases: const ['Period', 'Luteal'],
    content: '''
Diet plays a major role in managing PCOS-related symptoms because many of them are tied to insulin resistance. You don't need a restrictive diet — just smarter, more consistent choices.

Favor low glycemic index (low-GI) foods that release sugar slowly: whole grains like oats and brown rice, legumes, most vegetables, and fruits like apples, berries, and pears. Pairing carbs with protein or healthy fats (e.g., fruit with nuts) also slows sugar spikes.

Try to reduce processed sugar, sugary drinks, refined flour (maida), and heavily fried foods — these can worsen insulin resistance and inflammation over time. Include more fiber, lean protein (dal, eggs, paneer, fish), and anti-inflammatory foods like leafy greens, turmeric, and nuts.

Small, consistent changes matter more than a perfect diet. If you have PCOS/PCOD, a nutritionist or doctor can help build a plan tailored to your body and lab results.''',
  ),
  WellnessTopic(
    title: 'Exercise for Hormonal Health',
    category: 'Exercise',
    summary: 'The right mix of movement can meaningfully improve symptoms.',
    icon: Icons.fitness_center_rounded,
    relevantPhases: const ['Follicular', 'Ovulation'],
    content: '''
Regular movement is one of the most effective, low-cost tools for supporting hormonal balance — it improves insulin sensitivity, reduces stress hormones, and supports healthy weight management.

Strength training (2-3 times a week) helps build muscle, which improves how your body uses insulin. It doesn't need to mean heavy gym sessions — bodyweight exercises, resistance bands, or light dumbbells all count.

Brisk walking for 30 minutes most days is one of the simplest, most sustainable habits for hormonal health, and it's gentle enough to do daily. Yoga — especially poses like Malasana, Bhujangasana, and Suryanamaskar — can help reduce stress and support pelvic circulation, alongside its calming effect on the nervous system.

Avoid over-exercising or extreme calorie-burn routines, as excessive stress on the body can sometimes worsen hormonal imbalance rather than help it. Consistency and balance matter more than intensity.''',
  ),
  WellnessTopic(
    title: 'Stress and Your Hormones',
    category: 'Hormonal Health',
    summary: 'Why chronic stress quietly disrupts your cycle and hormones.',
    icon: Icons.self_improvement_rounded,
    relevantPhases: const ['Luteal'],
    content: '''
When you're stressed, your body releases cortisol — a hormone meant to help you handle short bursts of pressure. But when stress is constant, elevated cortisol can interfere with the hormones that regulate ovulation and your menstrual cycle.

This is why some people notice their periods becoming irregular, heavier, or even skipping during particularly stressful periods of life — exams, work deadlines, grief, or major life changes.

Managing stress doesn't require eliminating it (that's rarely possible) — it's about building small buffers: deep breathing for a few minutes a day, short walks, journaling, adequate sleep, and setting boundaries around constant screen time or overwork.

If stress feels overwhelming or constant, talking to a therapist or counselor is a valid and valuable form of care — mental health and hormonal health are closely connected.''',
  ),
  WellnessTopic(
    title: 'Why Sleep Matters for Hormones',
    category: 'Hormonal Health',
    summary: 'Poor sleep can throw off insulin, cortisol, and reproductive hormones.',
    icon: Icons.bedtime_rounded,
    relevantPhases: const ['Period', 'Luteal'],
    content: '''
Sleep is when your body does much of its hormonal repair and regulation work. Growth hormone, cortisol, insulin, and reproductive hormones like estrogen and progesterone all follow sleep-linked rhythms.

Consistently getting less than 6-7 hours of sleep, or having very irregular sleep timings, has been linked to higher insulin resistance, increased cravings, and disrupted menstrual cycles — this is especially relevant for people managing PCOS/PCOD.

Simple habits help: keeping a consistent sleep and wake time (even on weekends), reducing screen exposure an hour before bed, and keeping your room cool and dark. Avoiding caffeine late in the day also supports deeper sleep.

If you're sleeping enough hours but still waking up exhausted, or dealing with ongoing insomnia, it's worth discussing with a doctor — sleep issues can sometimes be a symptom of an underlying hormonal or thyroid condition.''',
  ),
  WellnessTopic(
    title: 'Understanding Your Cycle Phases',
    category: 'Hormonal Health',
    summary: 'Your cycle has four distinct phases, each with different hormone patterns.',
    icon: Icons.autorenew_rounded,
    relevantPhases: const ['Period', 'Follicular', 'Ovulation', 'Luteal'],
    content: '''
A typical menstrual cycle has four phases, each driven by different hormones. Understanding them can help you make sense of energy dips, mood shifts, and cravings across the month.

Menstrual phase (roughly days 1-5): estrogen and progesterone are at their lowest, which is why energy often feels lower during this time. Follicular phase (day 1 through ovulation): estrogen rises as the body prepares an egg, often bringing more energy and a better mood.

Ovulation (typically around day 14 in a 28-day cycle): a surge in luteinizing hormone (LH) triggers the release of an egg — this is usually when energy and confidence peak. Luteal phase (after ovulation until your next period): progesterone rises, then drops sharply just before menstruation, which is often when PMS symptoms like irritability or bloating appear.

Cycle length and phase timing vary from person to person and even cycle to cycle — this is normal within a reasonable range. Tracking your own patterns (like in this app's Cycle Tracker) can help you understand what's typical for you.''',
  ),
  WellnessTopic(
    title: 'When to See a Doctor',
    category: 'Self-Care',
    summary: 'Red flags that shouldn\'t be ignored — when to seek medical care.',
    icon: Icons.local_hospital_outlined,
    content: '''
Some symptoms are worth tracking casually. Others are worth acting on promptly. It's always okay to see a doctor for reassurance, but certain signs deserve more urgent attention.

Consider booking an appointment if you notice: periods that are absent for 3+ months (and you're not pregnant), periods that are extremely irregular over several cycles, very heavy bleeding (soaking through a pad/tampon every hour), severe pelvic pain that disrupts daily activities, sudden or excessive hair growth or hair loss, or unexplained, rapid weight changes.

Also see a doctor if you're trying to conceive and haven't after 12 months (or 6 months if you're over 35), or if PMS/mood symptoms feel severe enough to affect your relationships or work.

None of these symptoms alone confirm a specific diagnosis — but they're signals worth having checked rather than waiting out. Early evaluation almost always makes management easier.''',
  ),
  WellnessTopic(
    title: 'Self-Care Practices for Hormonal Health',
    category: 'Self-Care',
    summary: 'Everyday habits that gently support your hormonal balance.',
    icon: Icons.spa_rounded,
    relevantPhases: const ['Luteal'],
    content: '''
Hormonal health isn't only about diet and exercise — the small, everyday habits around rest, mindset, and body awareness matter too.

Build a gentle daily rhythm: consistent wake/sleep times, regular meals (skipping meals can affect blood sugar and, over time, hormones), and time outdoors for natural light exposure, which supports your circadian rhythm.

Practice body awareness without judgment — tracking your cycle, symptoms, and mood (like in this app) helps you notice patterns early rather than feeling blindsided each month. It's not about perfection, just information.

Make space for things that lower stress, even in small doses: a warm bath, a short walk, journaling, or simply saying no to something that's overwhelming you. Self-care here isn't indulgence — it's a genuine part of hormonal health.''',
  ),
  WellnessTopic(
    title: 'PCOS/PCOD and Skin Changes',
    category: 'PCOS',
    summary: 'Why hormonal acne and skin changes happen, and what helps.',
    icon: Icons.face_retouching_natural_rounded,
    relevantPhases: const ['Period'],
    content: '''
Hormonal imbalances linked to PCOS/PCOD often show up on the skin before anything else — which is part of why this app pairs skin tracking with wellness tracking.

Elevated androgens (male hormones present in smaller amounts in everyone) can increase oil production, leading to acne that tends to cluster along the jawline, chin, and lower cheeks, and often flares around your period. Some people also notice patches of darkened, velvety skin (a sign of insulin resistance) or increased facial/body hair growth.

Managing the skin symptom alone (with topical treatments) can help, but addressing the underlying hormonal pattern — through diet, sleep, stress management, and medical care when needed — tends to produce more lasting improvement.

If jawline acne is persistent and doesn't respond to typical skincare, it's worth mentioning to both a dermatologist and a gynecologist, since it can be a useful clue about what's happening hormonally.''',
  ),
  WellnessTopic(
    title: 'Building a Sustainable Routine',
    category: 'Self-Care',
    summary: 'Small, consistent habits beat drastic short-term changes.',
    icon: Icons.checklist_rounded,
    content: '''
One of the most common mistakes in managing hormonal health is going all-in on drastic changes for two weeks, then burning out. Sustainable habits — even small ones — tend to produce far better long-term results.

Start with just one or two changes at a time: maybe a consistent sleep schedule first, then gradually improving meals, then adding movement. Trying to overhaul diet, exercise, sleep, and stress all at once is rarely sustainable and can add its own stress.

Track your patterns loosely rather than obsessively — noting your cycle, mood, and symptoms (like in this app's Cycle and Symptom trackers) helps you see what's actually working over weeks and months, not just days.

Progress with hormonal health is usually gradual and non-linear. Some months will feel better than others, and that's normal — consistency over time matters more than any single "perfect" week.''',
  ),
];