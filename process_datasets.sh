#!/bin/bash
set -e

nproc=48
procdir=$(pwd)

process () {
dataset=$1
dials.import "${procdir}"/"${dataset}"/"${dataset}"_*.mrc goniometer.axes=1,0,0 distance=838.5 panel.pedestal=-64
dials.generate_mask imported.expt untrusted.circle='1031 1023 50' untrusted.polygon='0 1010 600 1010 976 1004 988 998 986 1044 978 1041 650 1051 0 1051'
dials.apply_mask imported.expt mask=pixels.mask
dials.find_spots masked.expt d_min=0.8 nproc="${nproc}"
dials.search_beam_position masked.expt strong.refl
dials.index optimised.expt strong.refl detector.fix=distance
dials.refine indexed.expt indexed.refl detector.fix=distance scan_varying=false output.experiments=refined_static.expt output.reflections=refined_static.refl
dials.refine refined_static.expt refined_static.refl detector.fix=distance scan_varying=true
dials.integrate refined.expt refined.refl nproc="${nproc}"
}

i=1
for dataset in biotin_xtal1 biotin_xtal2 biotin_xtal3 biotin_xtal4 biotin_xtal5_recentre biotin_xtal6 biotin_xtal7 biotin_xtal8 biotin_xtal9 biotin_xtal10 biotin_xtal11_recentre; 
do
  workdir=$(printf "xtal_%03d" $i)
  mkdir -p "${workdir}" && cd "${workdir}"
  process "${dataset}"
  cd "${procdir}"
  i=$((i+1))
done
