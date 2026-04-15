#!/usr/bin/env python3
"""Generates a moan.wav sound file using pure Python."""
import wave, math, struct, os

def generate_moan(filename, duration=1.5, sample_rate=44100):
    num_samples = int(duration * sample_rate)

    def freq_at(t):
        # Rise from 240Hz to 420Hz at 55%, then fall to 190Hz
        if t < 0.55:
            return 240 + (420 - 240) * (t / 0.55)
        else:
            return 420 - (420 - 190) * ((t - 0.55) / 0.45)

    def amp_at(t):
        # Fade in over 8%, fade out over last 20%
        if t < 0.08:
            return t / 0.08
        elif t > 0.80:
            return (1.0 - t) / 0.20
        return 1.0

    samples = []
    phase = 0.0

    for i in range(num_samples):
        t = i / num_samples
        f = freq_at(t) + 8 * math.sin(2 * math.pi * 5.5 * i / sample_rate)  # vibrato
        phase += 2 * math.pi * f / sample_rate
        a = amp_at(t) * 0.65
        s = (a * math.sin(phase)
             + 0.28 * a * math.sin(2 * phase)   # 2nd harmonic
             + 0.08 * a * math.sin(3 * phase))  # 3rd harmonic
        samples.append(int(max(-1.0, min(1.0, s)) * 32767))

    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        f.writeframes(struct.pack(f'<{len(samples)}h', *samples))

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'moan.wav')
generate_moan(out)
print(f"Generated {out}")
