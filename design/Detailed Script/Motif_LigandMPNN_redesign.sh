#!/bin/bash
#SBATCH -J dnd
#SBATCH -N 1
#SBATCH -c 8
#SBATCH -p cpu,test
#SBATCH --mem 32g
## SBATCH --gres=gpu:1

module load apps/anaconda3/2021.05
conda activate ******/.conda/envs/ligandmpnn_env/



# 定义输入文件夹和输出文件夹
pdb_folder="******/input/"
outpath="*****/output/"

# 如果输出文件夹不存在，则创建
if [[ ! -e $outpath ]]; then
    mkdir -p $outpath
fi

# 遍历文件夹中的每个 PDB 文件
for pdb_file in "$pdb_folder"*.pdb; do
    pdb_basename=$(basename "$pdb_file" .pdb)
    output_dir="$outpath/$pdb_basename"

    # 使用 Python 计算符合条件的残基编号
    redesigned_residues=$(python3 - <<EOF
from Bio import PDB
import sys

pdb_file = "$pdb_file"
parser = PDB.PDBParser(QUIET=True)
structure = parser.get_structure('PDB', pdb_file)

A_residues = []
B_CA_atoms = []

for model in structure:
    for chain in model:
        if chain.id == 'B':
            for residue in chain:
                for atom in residue:
                    if atom.id == 'CA' and atom.full_id[3][0].startswith((' ', 'H')):
                        B_CA_atoms.append(atom)

for model in structure:
    for chain in model:
        if chain.id == 'A':
            for residue in chain:
                if 'CA' in residue:
                    ca_atom = residue['CA']
                    if all(ca_atom - b_ca > 9.0 for b_ca in B_CA_atoms):
                        A_residues.append(f"A{residue.id[1]}")

print(" ".join(A_residues))
EOF
)

    # 将 redesigned_residues 写入日志文件
    echo "Redesigned residues for $pdb_file: $redesigned_residues" >> "$outpath/redesign_log.txt"

    # 运行 LigandMPNN
    python /*****/software/LigandMPNN/run.py \
        --seed 111 \
        --pdb_path "$pdb_file" \
        --out_folder "$output_dir" \
        --model_type "ligand_mpnn" \
        --redesigned_residues "$redesigned_residues" \
        --temperature 0.05 \
        --batch_size 1 \
        --number_of_batches 10 \
        --checkpoint_ligand_mpnn "*****/software/LigandMPNN/model_params/ligandmpnn_v_32_010_25.pt"
    
    echo "Processing completed for $pdb_file"
done

echo "All PDB files processed."
