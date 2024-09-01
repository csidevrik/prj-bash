#!/bin/bash

# Frecuencia base en Hz
base_freq=440

# Diferencia de frecuencia entre los oídos en Hz (para el efecto binaural)
binaural_diff=10

# Duración del sonido en segundos
duration=5

# Frecuencias para los oídos izquierdo y derecho
left_freq=$base_freq
right_freq=$(echo "$base_freq + $binaural_diff" | bc)

# Generar el sonido binaural usando sox
# sox -n -p synth $duration sine $left_freq vol -3dB \
# | sox -n -p synth $duration sine $right_freq vol -3dB \
# | sox -m - -c 2 -t wav output_binaural.wav

sox -n -p synth $duration sine $left_freq vol -3dB \
| sox -m - -c 2 -t wav output_binaural.wav synth $duration sine $right_freq vol -3dB
