#!/usr/bin/env python3
"""Generates an original, upbeat, royalty-free modern tech/IoT background soundtrack WAV.
Zero external dependencies (Python stdlib only). Usage: make_music.py <duration_sec> <out.wav>
"""
import math, random, struct, sys, wave

SR = 44100

def mtof(m):
    return 440.0 * (2.0 ** ((m - 69) / 12.0))

def generate(dur, out_path):
    n_samples = int(dur * SR)
    bpm = 118.0
    beat_s = 60.0 / bpm
    bar_s = beat_s * 4
    sixteenth_s = beat_s / 4.0

    # Modern uplifting tech-pop progression: Fmaj7 -> G6 -> Em7 -> Am9 (1 bar each)
    chords = [
        [53, 57, 60, 64],  # Fmaj7
        [55, 59, 62, 64],  # G6
        [52, 55, 59, 62],  # Em7
        [57, 60, 64, 71],  # Am9
    ]
    roots = [41, 43, 40, 45]  # F2, G2, E2, A2
    arp_pattern = [0, 2, 1, 3, 2, 3, 1, 2]

    buf_l = [0.0] * n_samples
    buf_r = [0.0] * n_samples
    rng = random.Random(108)

    # Pre-build crisp punchy kick + airy hi-hat + soft snap
    kick_len = int(0.20 * SR)
    kick = []
    ph = 0.0
    for i in range(kick_len):
        t = i / SR
        freq = 46.0 + 74.0 * math.exp(-t * 38.0)
        ph += 2.0 * math.pi * freq / SR
        env = math.exp(-t * 15.0) * min(1.0, t * 420.0)
        kick.append(math.sin(ph) * env * 0.40)

    hat_len = int(0.04 * SR)
    hat = []
    prev = 0.0
    for i in range(hat_len):
        t = i / SR
        w = rng.uniform(-1.0, 1.0)
        hp = w - prev * 0.87
        prev = w
        hat.append(hp * math.exp(-t * 105.0) * 0.065)

    snap_len = int(0.09 * SR)
    snap = []
    prev_s = 0.0
    for i in range(snap_len):
        t = i / SR
        w = rng.uniform(-1.0, 1.0)
        bp = (w - prev_s * 0.6) * math.sin(2.0 * math.pi * 1850.0 * t)
        prev_s = w
        snap.append(bp * math.exp(-t * 48.0) * 0.14)

    # 1. Drums (clean 4-on-the-floor kick, soft off-beat snap on beats 2 & 4, crisp hats)
    total_beats = int(dur / beat_s) + 1
    for b in range(total_beats):
        start = int(b * beat_s * SR)
        if b < 2:
            continue
        for i in range(kick_len):
            idx = start + i
            if idx < n_samples:
                buf_l[idx] += kick[i]
                buf_r[idx] += kick[i]
        if b % 2 == 1 and b >= 4:
            for i in range(snap_len):
                idx = start + i
                if idx < n_samples:
                    buf_l[idx] += snap[i] * 0.9
                    buf_r[idx] += snap[i] * 1.1

    total_16 = int(dur / sixteenth_s) + 1
    for s in range(total_16):
        if s % 4 == 0:
            continue
        accent = 1.0 if (s % 4 == 2) else 0.4
        start = int(s * sixteenth_s * SR)
        pan_l = 0.62 if (s % 2 == 0) else 0.42
        pan_r = 1.04 - pan_l
        for i in range(hat_len):
            idx = start + i
            if idx < n_samples:
                v = hat[i] * accent
                buf_l[idx] += v * pan_l
                buf_r[idx] += v * pan_r

    # 2. Warm sidechained synth pad + smooth synth bass + glassy tech pluck arpeggio
    total_bars = int(dur / bar_s) + 1
    for bar in range(total_bars):
        ci = bar % len(chords)
        chord = chords[ci]
        root_f = mtof(roots[ci])
        bar_start = int(bar * bar_s * SR)
        bar_len = int(bar_s * SR)

        freqs = [mtof(n) for n in chord]
        for i in range(bar_len):
            idx = bar_start + i
            if idx >= n_samples:
                break
            t = i / SR
            beat_phase = (t % beat_s) / beat_s
            duck = 0.52 + 0.48 * min(1.0, beat_phase * 3.8)
            env = min(1.0, t * 7.5) * min(1.0, (bar_s - t) * 7.5) * duck * 0.062
            sl = 0.0
            sr = 0.0
            for fi, f in enumerate(freqs):
                det = 1.002 if (fi % 2 == 0) else 0.998
                sl += math.sin(2.0 * math.pi * f * t) + 0.18 * math.sin(4.0 * math.pi * f * t)
                sr += math.sin(2.0 * math.pi * f * det * t) + 0.18 * math.sin(4.0 * math.pi * f * det * t)
            buf_l[idx] += sl * env
            buf_r[idx] += sr * env

        # Clean rhythmic sub-bass pulse
        for step in range(8):
            if step in (0, 2, 3, 5, 6):
                st = bar_start + int(step * (beat_s / 2.0) * SR)
                blen = int(0.24 * SR)
                for i in range(blen):
                    idx = st + i
                    if idx >= n_samples:
                        break
                    t = i / SR
                    env = min(1.0, t * 130.0) * math.exp(-t * 8.0) * 0.155
                    v = math.sin(2.0 * math.pi * root_f * t) + 0.25 * math.sin(4.0 * math.pi * root_f * t)
                    buf_l[idx] += v * env
                    buf_r[idx] += v * env

        # Glassy digital pluck arpeggio (8th notes, gentle stereo ping-pong)
        for step in range(8):
            note = chord[arp_pattern[step]] + 12
            f = mtof(note)
            st = bar_start + int(step * (beat_s / 2.0) * SR)
            plen = int(0.26 * SR)
            pan = 0.34 if (step % 2 == 0) else 0.66
            for i in range(plen):
                idx = st + i
                if idx >= n_samples:
                    break
                t = i / SR
                env = min(1.0, t * 280.0) * math.exp(-t * 11.5) * 0.088
                v = (
                    math.sin(2.0 * math.pi * f * t)
                    + 0.32 * math.sin(4.0 * math.pi * f * t) * math.exp(-t * 16.0)
                    + 0.12 * math.sin(6.0 * math.pi * f * t) * math.exp(-t * 28.0)
                )
                buf_l[idx] += v * env * (1.0 - pan) * 1.4
                buf_r[idx] += v * env * pan * 1.4

    # 3. Gentle fade-in / fade-out + normalization
    fade_in = int(0.6 * SR)
    fade_out = int(2.2 * SR)
    peak = max(1e-6, max(max(abs(x) for x in buf_l), max(abs(x) for x in buf_r)))
    gain = 0.72 / peak

    frames = bytearray(n_samples * 4)
    for i in range(n_samples):
        env = 1.0
        if i < fade_in:
            env = i / fade_in
        elif i > n_samples - fade_out:
            env = max(0.0, (n_samples - i) / fade_out)
        l = max(-0.98, min(0.98, buf_l[i] * gain * env))
        r = max(-0.98, min(0.98, buf_r[i] * gain * env))
        struct.pack_into("<hh", frames, i * 4, int(l * 32767), int(r * 32767))

    with wave.open(out_path, "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(frames)

if __name__ == "__main__":
    generate(float(sys.argv[1]), sys.argv[2])
