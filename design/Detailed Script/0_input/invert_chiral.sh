#!/usr/bin/env python

import sys
from pyrosetta import *
#from rosetta.core.conformation import ResidueFactory

def main(input_pdb, output_pdb):

    init("-mute all")

    pose = pose_from_pdb(input_pdb)

    # ========= 1. 镜像坐标变换 =========
    for t in range(0, len(pose.residues)):
        for i in range(0, len(pose.residue(t+1).atoms())):
            pose.residue(t+1).set_xyz(i+1,pose.residue(t+1).xyz(pose.residue(t+1).atom_name(i+1)).negate())
            print (pose.residue(t+1).xyz(pose.residue(t+1).atom_name(i+1)))
  
    # ========= 输出 =========
    pose.dump_pdb(output_pdb)


if __name__ == "__main__":

    if len(sys.argv) != 3:
        print("Usage:")
        print("  python invert_chiral.py input.pdb output.pdb")
        sys.exit(1)

    input_pdb = sys.argv[1]
    output_pdb = sys.argv[2]

    main(input_pdb, output_pdb)
