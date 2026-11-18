# 🔥 Strive — Road to UTBK, TKA & Sekolah Kedinasan 2027

Aplikasi Android **100% Pure Native Flutter (Material 3)** untuk pejuang **UTBK-SNBT**, **TKA Saintek/Soshum**, dan **Sekolah Kedinasan (SKD CAT BKN, Psikotes Pauli/Kraepelin & Tes Fisik Samapta)** menuju tahun 2027.

---

## ✨ Fitur Utama

### 1. 🐯 Interactive Mascot Engine: "IGNIS" (Phoenix-Tiger)
Dibangun 100% *native* menggunakan `CustomPainter`, `AnimatedContainer`, dan `TweenAnimationBuilder` tanpa aset gambar eksternal:
- **Happy / Hype Mode**: Muncul saat mencatat menit belajar, mencetak rekor TryOut baru, atau menyelesaikan $\ge 10$ Pull-up.
- **Angry / Guilt-Trip Duolingo Mode**: Muncul setelah pukul 18:00 WIB jika *streak* hari ini masih 0 atau jika subtes SKD gagal memenuhi ambang batas (*Nilai Mati*).
- **Crying / Frozen Mode**: Muncul saat *Streak Freeze* terpakai atau *streak* kembali ke 0.
- **Coach / Spartan Headband Mode**: Muncul di kalkulator & stopwatch fisik Samapta mengenakan ikat kepala taktis Spartan.
- **Burnout Doctor Mode**: Muncul otomatis saat pengguna mencatat *"Otak/Badan Ngebul"* 3 kali berturut-turut.

### 2. 🎮 Desain 3D Tactile ("Duolingo Evolved") & Dual RPG Boss Fights
- **`Strive3DButton` & `Strive3DCard`**: Tombol 3D dengan *bottom lip* 5px yang menekan secara fisik sejauh 4px saat disentuh (`HapticFeedback.lightImpact()`).
- **Dual RPG Boss Cards**:
  - **Academic Boss (PTN & SKD)**: HP Boss dihitung secara *real-time* dari selisih skor rata-rata pengguna terhadap Target Passing Grade.
  - **Physical Boss (Samapta Readiness)**: HP Boss dihitung dari skor keseluruhan Samapta (0–100) terhadap ambang batas fisik aman ($70+$).
- **Duolingo-Style Winding Journey Map** & **GitHub-Style Contribution Heatmap (84 Hari)**.

### 3. 📈 Deep Analytics & Diagram Kartesius Bulanan (`fl_chart`)
- **Diagram Kartesius 1 (`LineChart`)**: Trajectory skor bulanan dengan garis putus-putus horizontal (`ExtraLinesData`) untuk Target Passing Score.
- **Diagram Kartesius 2 (`ScatterChart` 4-Kuadran Effort vs. Score)**:
  - **Kuadran I (High Effort, High Score)**: *Mastered / Pertahankan* (Emerald)
  - **Kuadran II (Low Effort, High Score)**: *Bakat Alami* (Sky)
  - **Kuadran III (Low Effort, Low Score)**: *Zona Bahaya / Kurang Latihan* (Rose)
  - **Kuadran IV (High Effort, Low Score)**: *Evaluasi Metode Belajar/Latihan* (Amber)
- **Multi-Track `RadarChart` & Deficit Gap Analyzer Card**.

### 4. 🏋️ Logger TryOut, SKD CAT BKN, Psikotes & Kalkulator Fisik Samapta + Ignis AI Coach
- **Logger UTBK & TKA**: Catat 7 subtes UTBK (`PU, PPU, PBM, PK, LBI, LBE, PM`) dan TKA Saintek/Soshum lengkap dengan *delta chips* (`+pts` / `-pts`).
- **Logger SKD & Psikotes**: Validasi otomatis ambang batas BKN (`TWK >= 65`, `TIU >= 80`, `TKP >= 166`) dengan badge **LULUS AMBANG BATAS** atau **GUGUR (NILAI MATI)**, serta pelacak Kecermatan Pauli/Kraepelin.
- **Kalkulator Samapta A & B (Pria & Wanita) + Ignis AI Coach**:
  - Konversi otomatis Lari 12 Menit, Pull-up (Pria) / Chinning (Wanita), Sit-up, Push-up, Shuttle Run $6\times 10\text{ m}$, dan Renang $25\text{ m}$ ke skala 0–100.
  - Rumus resmi: $\text{Skor Akhir} = \frac{\text{Skor A} + \text{Rata-rata Skor B}}{2}$.
  - **Resep Progressive Overload Mingguan**: Diagnosis defisit repetisi/jarak otomatis beserta resep latihan mingguan.

### 5. ⏱️ Pomodoro Akademik, Stopwatch Samapta 60s, Cooper 12m & 100% Offline JSON Backup
- Timer Pomodoro Akademik & Stopwatch Samapta 60 detik (*audio/haptic beep*) + Cooper Test 12 Menit dengan `WakelockPlus`.
- Checklist Silabus 3D 3-Status (`Merah`, `Kuning`, `Hijau`) & **Offline Ammunition Vault**.
- **Time Capsule Mei 2027**, **Mascot & Streak Shop**, **Demo Data 4 Bulan**, dan **Export/Import JSON Backup**.

---

## 🚀 Cara Build `.APK`

```bash
flutter pub get
flutter analyze
flutter build apk --release
```
