# D-protein_binder_design
This repository documents a computational protocol for the de novo design of **heterochiral D-protein binders** that recognize **L-target proteins**. The workflow combines target preparation, docking, Rosetta-based design, motif extraction, Chai-1 / AlphaFold2 structure prediction, and LigandMPNN sequence design.



---

## 1. Overview

The goal of this protocol is to generate computationally designed D-protein or D-peptide binders that can bind a native L-target protein surface. The workflow proceeds from an input target structure through scaffold docking, Rosetta  design, motif extraction, heterochiral complex prediction, sequence redesign, and final structure prediction.

The main stages are:

1. Project initialization
2. D-target preparation
3. Rifgen target modeling
4. Polyvaline scaffold preparation
5. PatchDock rigid-body docking
6. RifDock flexible docking
7. Pre-processing of docking outputs
8. Rosetta predictor filtering
9. Pilot Rosetta design runs
10. FastDesign runs on selected docking outputs
11. Motif extraction, clustering, and hotspot identification
12. Chai-1 prediction of D-motif / L-target complexes
13. Grafting validated motifs into helical scaffolds
14. LigandMPNN binder sequence design
15. AlphaFold2 binder monomer prediction
16. rChai-1 prediction of the final heterochiral D-binder / L-target complex

---

## 2. Scope and Assumptions

This protocol assumes that the user has access to:

- A Linux-based workstation or HPC cluster
- Appropriate licenses or academic access to the required software
- The target protein structure in PDB/CIF format
- A scaffold library for binder design
- Basic command-line experience
- Familiarity with Rosetta, PyRosetta, Jupyter notebooks, and structure prediction tools

The protocol is written as a reproducible project workflow. Exact file paths, queueing-system commands, and tool flags may need to be adapted to the local environment.

---

## 3. Pipeline Summary

| Stage | Directory | Main Input | Main Output | Main Tools |
|---:|---|---|---|---|
| 1 | `0_Input` | Raw target and scaffold list | Initialized project structure | Shell |
| 2 | `0_Input` | Target PDB | Prepared D-version target | PyRosetta, shell scripts |
| 3 | `1_Rifgen` | Prepared target, Rifgen residues | Rifgen target model and log | Rifgen / RifDock |
| 4 | `2_Polyval_Scaffolds` | Scaffold PDBs | Polyvaline scaffolds | Python helper script |
| 5 | `3_PatchDock` | Polyvaline scaffolds, Rifgen target | PatchDock docking poses | PatchDock |
| 6 | `4_RifDock` | PatchDock outputs, RifDock flags | RifDock docking solutions | RifDock |
| 7 | `4_RifDock` | RifDock outputs | Corrected D-target docking outputs | Shell / Perl helper scripts |
| 8 | `5_FastDesign` | Preprocessed docking outputs | Filtered docking candidates | RosettaScripts |
| 9 | `5_FastDesign` | Selected docking candidates | Pilot design scores | RosettaScripts |
| 10 | `5_FastDesign` | Pilot-filtered candidates | FastDesign outputs | RosettaScripts |
| 11 | `6_Motif_Selection` | FastDesign outputs | Clustered motifs and hotspots | Python, motif clustering, Jupyter |
| 12 | `7_Chai1_Dpeptide` | Motifs, target, LigandMPNN sequences | Validated D-peptide / L-target complexes | LigandMPNN, Chai-1 |
| 13 | `8_Grafting` | Validated motifs, helical scaffolds | Grafted scaffold candidates | RosettaScripts |
| 14 | `9_Binder_Sequence_Design` | Grafted complexes | Redesigned binder sequences | LigandMPNN |
| 15 | `10_AF2_Binder` | Binder sequences | Predicted binder monomer structures | AlphaFold2 |
| 16 | `11_rChai1_Complex` | Predicted binders and target | Final heterochiral complex predictions | rChai-1 |

---

## 4. Recommended Project Structure

A recommended directory layout is:

```text
PROJECT/
├── 0_Input/
├── 1_Rifgen/
├── 2_Polyval_Scaffolds/
├── 3_PatchDock/
├── 4_RifDock/
├── 5_FastDesign/
├── 6_Motif_Selection/
├── 7_Chai1_Dpeptide/
├── 8_Grafting/
├── 9_Binder_Sequence_Design/
├── 10_AF2_Binder/
├── 11_rChai1_Complex/
├── scripts/
├── flags/
├── notebooks/
├── logs/
└── data/
```

A more detailed layout can be:

```text
PROJECT/
├── 0_Input/
│   ├── target_raw.pdb
│   ├── target.pdb
│   ├── scaffold_list.txt
│   └── rifgen_residues.list
├── 1_Rifgen/
│   ├── rifgen.flags
│   ├── rifgen.log
│   └── rifgen_output/
├── 2_Polyval_Scaffolds/
│   ├── scaffolds/
│   └── polyvaline_scaffolds/
├── 3_PatchDock/
│   ├── params/
│   └── outputs/
├── 4_RifDock/
│   ├── rifdock.flags
│   ├── raw_outputs/
│   └── preprocessed_outputs/
├── 5_FastDesign/
│   ├── predictor/
│   ├── pilot/
│   └── fastdesign/
├── 6_Motif_Selection/
│   ├── extracted_motifs/
│   ├── clustered_motifs/
│   └── hotspots/
├── 7_Chai1_Dpeptide/
│   ├── ligandmpnn_sequences/
│   ├── chai1_inputs/
│   └── chai1_outputs/
├── 8_Grafting/
│   ├── graft_inputs/
│   └── graft_outputs/
├── 9_Binder_Sequence_Design/
│   ├── ligandmpnn_inputs/
│   └── ligandmpnn_outputs/
├── 10_AF2_Binder/
│   ├── sequences/
│   └── predictions/
├── 11_rChai1_Complex/
│   ├── inputs/
│   └── predictions/
├── scripts/
├── flags/
├── notebooks/
├── logs/
└── data/
```

> If your existing project uses folder names with spaces, for example `1. Rifgen`, you may keep those names. For command-line workflows, underscored names such as `1_Rifgen` are often easier to use.

---

## 5. Software and Licensing

This protocol uses the following third-party software and resources.

| Software | Version / Terms | Source |
|---|---|---|
| Chai-1 | Released under the Apache 2.0 License | [https://github.com/chaidiscovery/chai-lab](https://github.com/chaidiscovery/chai-lab) |
| Rosetta Modeling Suite | Version 2019.47.61047; available free of charge to academic and non-commercial users | [https://www.rosettacommons.org/](https://www.rosettacommons.org/) |
| LigandMPNN | Source code available | [https://github.com/dauparas/LigandMPNN](https://github.com/dauparas/LigandMPNN) |
| RifDock / RIF docking | Source code available | [https://github.com/rifdock/rifdock](https://github.com/rifdock/rifdock) |

Additional tools used in the workflow include:

- PyRosetta
- RosettaScripts
- PatchDock
- AlphaFold2
- rChai-1(provided in this project)
- Jupyter Notebook
- Python helper scripts
- Perl helper scripts

### License Notice

Chai-1 prediction is released under the Apache 2.0 License ([https://github.com/chaidiscovery/chai-lab](https://github.com/chaidiscovery/chai-lab)). The Rosetta Modeling Suite 2019.47.61047 ([https://www.rosettacommons.org/](https://www.rosettacommons.org/)) is available free of charge to academic and non-commercial users. LigandMPNN is accessible at [https://github.com/dauparas/LigandMPNN](https://github.com/dauparas/LigandMPNN), and the source code for RIF docking is available at [https://github.com/rifdock/rifdock](https://github.com/rifdock/rifdock).

> Please check the license terms of each software package before commercial use, redistribution, or incorporation into downstream products.

---

## 6. Conventions Used in This Protocol

### Chirality Conventions

- **L-target:** A target protein or peptide composed of L-amino acids.
- **D-binder / D-peptide:** A designed binding element composed of D-amino acids or containing D-chiral sequence regions.
- **Heterochiral complex:** A complex formed between a D-chiral binder and an L-chiral target.

### File Conventions

Common file types in this workflow include:

| Extension | Meaning |
|---|---|
| `.pdb` | Protein structure file |
| `.list` | Text list of residues, scaffolds, motifs, or PDB files |
| `.flags` | Rosetta or RifDock flag file |
| `.xml` | RosettaScripts parser script |
| `.sc` | Score file |
| `.log` | Program output log |
| `.dat` | Data table |
| `.ipynb` | Jupyter notebook |

### General Rule

Do not overwrite earlier results. Store new runs in dated, versioned, or stage-specific subfolders.

---

## 7. Pre-Start Checklist

Before beginning the protocol, confirm that the following are available:

- [ ] Target protein PDB file
- [ ] Scaffold library PDB files
- [ ] List of scaffolds to be used
- [ ] Selected Rifgen residues
- [ ] Rifgen flag file
- [ ] RifDock flag file
- [ ] PatchDock parameter files
- [ ] Rosetta XML and flags files:
  - [ ] `predictor.xml`
  - [ ] `predictor.flags`
  - [ ] `design.xml`
  - [ ] `pilot.flags`
  - [ ] `fastdesign.flags`
  - [ ] `graft.xml`
  - [ ] `graft.flags`
- [ ] Python helper scripts
- [ ] Perl helper scripts
- [ ] Jupyter notebooks
- [ ] HPC job submission scripts, if applicable
- [ ] Sufficient CPU, memory, and disk space

---

# 8. Step-by-Step Protocol

---

## Step 1. Project Initialization

Create the project directory and enter it.

```bash
mkdir -p Heterochiral_D_Binder
cd Heterochiral_D_Binder
```

Create the main stage directories.

```bash
mkdir -p \
  0_Input \
  1_Rifgen \
  2_Polyval_Scaffolds \
  3_PatchDock \
  4_RifDock \
  5_FastDesign \
  6_Motif_Selection \
  7_Chai1_Dpeptide \
  8_Grafting \
  9_Binder_Sequence_Design \
  10_AF2_Binder \
  11_rChai1_Complex
```

Create auxiliary directories for scripts, flags, notebooks, logs, and raw data.

```bash
mkdir -p scripts flags notebooks logs data
```

Place the initial input files in `0_Input/`.

Expected input files:

```text
0_Input/
├── target_raw.pdb
├── scaffold_list.txt
└── rifgen_residues.list
```

---

## Step 2. Target Preparation

The target structure must be prepared as a single-chain D-version target before downstream docking.

Work in:

```bash
cd 0_Input
```

### 2.1 Invert Target Chirality

If a PyRosetta-based chirality inversion script is available, use it to generate the D-version target.

Example:

```bash
python invert_chiral.py target_raw.pdb target_d.pdb
mv target_d.pdb target.pdb
```

### 2.2 Ensure Single-Chain Format and Set Chain A

The target should be reduced to a single chain and assigned chain ID `A`.

Example command:

```bash
cat target.pdb | grep '^ATOM' | sed 's/./A/22' > tmp.pdb
mv tmp.pdb target.pdb
```

### 2.3 Verification

Before continuing, verify that:

- The file contains protein atoms.
- The chain ID is correct.
- Residue numbering is sensible.
- The PDB file can be opened by the downstream tools.

A quick check can be performed with:

```bash
grep '^ATOM' target.pdb | awk '{print $22}' | sort | uniq
```

Expected output for a single-chain target:

```text
A
```

---

## Step 3. Rifgen

Rifgen is used to generate the target model required for PatchDock.

Work in:

```bash
cd 1_Rifgen
```

### 3.1 Prepare Rifgen Residue List

Create or edit:

```text
rifgen_residues.list
```

The file should contain one residue identifier per line.

Example:

```text
A:10
A:25
A:42
```

> Use the residue naming convention expected by your Rifgen setup.

### 3.2 Prepare Rifgen Flags

Edit the I/O section of:

```text
rifgen.flags
```

Confirm that the input target, output directory, log file, and other paths are correct.

### 3.3 Run Rifgen

Rifgen is distributed with the RifDock package:

[https://github.com/rifdock/rifdock](https://github.com/rifdock/rifdock)

A typical HPC job script may look like the following:

```bash
#!/bin/bash
# rifgen.sbatch

#SBATCH -J rifgen
#SBATCH -c 16
#SBATCH --mem=100G
#SBATCH -t 12:00:00
#SBATCH -o rifgen.out

source /path/to/your/environment

rifgen @rifgen.flags
```

Submit the job using your cluster system, for example:

```bash
sbatch rifgen.sbatch
```

### 3.4 Expected Rifgen Outputs

After the run completes, locate:

- The Rifgen log file, for example `rifgen.log`
- The Rifgen output target PDB file

Important:

- Save the Rifgen log.
- The output PDB from Rifgen is used for PatchDock.
- Convert the Rifgen output PDB to chain `B` before using it in downstream docking.

Recommended resource allocation:

| Resource | Recommendation |
|---|---:|
| CPUs | 16 |
| RAM | 100 GB |
| Runtime | approximately 8 hours |

---

## Step 4. Polyvaline Scaffold Library

Scaffolds must be converted to polyvaline form before PatchDock.

Work in:

```bash
cd 2_Polyval_Scaffolds
```

### 4.1 Prepare Scaffold List

Create a scaffold list file, for example:

```text
scaffold_list.txt
```

Each line can contain the path to a scaffold PDB file.

### 4.2 Convert Scaffolds to Polyvaline

Use the provided helper script, for example:

```bash
python mutate_polyXXX.py scaffold.pdb scaffold_polyval.pdb
```

For batch conversion:

```bash
for scaffold in scaffolds/*.pdb; do
  basename_scaf=$(basename "$scaffold" .pdb)
  python mutate_polyXXX.py "$scaffold" "polyvaline_scaffolds/${basename_scaf}_polyval.pdb"
done
```

### 4.3 Expected Outputs

Store converted scaffolds in:

```text
2_Polyval_Scaffolds/polyvaline_scaffolds/
```

Verify that each scaffold:

- Is valid PDB format.
- Has the expected chain ID.
- Contains only the expected backbone or scaffold atoms.

---

## Step 5. PatchDock

PatchDock is used to generate rigid-body docking poses between the polyvaline scaffolds and the Rifgen target.

Work in:

```bash
cd 3_PatchDock
```

### 5.1 Prepare PatchDock Parameter Files

For each scaffold, prepare a PatchDock parameter file, for example:

```text
params/
├── scaffold_01.params
├── scaffold_02.params
└── scaffold_03.params
```

The parameter files should point to:

- The correct polyvaline scaffold PDB
- The correct Rifgen target PDB
- The desired output prefix
- Any PatchDock constraints or search parameters

### 5.2 Run PatchDock

Example single-scaffold command:

```bash
patch_dock.Linux ${scaf}.params ${scaf}.out
```

Example batch command:

```bash
for params in params/*.params; do
  scf=$(basename "$params" .params)
  patch_dock.Linux "params/${scf}.params" "outputs/${scf}.out"
done
```

### 5.3 Expected Outputs

PatchDock outputs should contain docking positions or poses for each scaffold.

Store outputs in:

```text
3_PatchDock/outputs/
```

For downstream RifDock, a typical scaffold may produce several thousand positions.

---

## Step 6. RifDock

RifDock is used to refine the PatchDock docking solutions.

Work in:

```bash
cd 4_RifDock
```

### 6.1 Prepare RifDock Flags

Create or edit:

```text
rifdock.flags
```

Open the Rifgen log file from Step 3 and scroll to the bottom. Locate the section containing the docking information required by RifDock. Copy that section into the top of `rifdock.flags`.

### 6.2 Run RifDock

RifDock is available from:

[https://github.com/rifdock/rifdock](https://github.com/rifdock/rifdock)

A typical HPC job script may look like the following:

```bash
#!/bin/bash
# rifdock.sbatch

#SBATCH -J rifdock
#SBATCH -c 16
#SBATCH --mem=200G
#SBATCH -t 4:00:00
#SBATCH -o rifdock.out

source /path/to/your/environment

rifdock @rifdock.flags
```

Submit the job:

```bash
sbatch rifdock.sbatch
```

> The exact executable name and flag syntax may vary depending on your RifDock installation. Consult the RifDock documentation for your version.

### 6.3 Expected Outputs

Store raw RifDock outputs in:

```text
4_RifDock/raw_outputs/
```

Typical resource requirement for one approximately 20 kDa scaffold with around 3,000 PatchDock positions:

| Resource | Recommendation |
|---|---:|
| CPUs | 16 |
| RAM | 200 GB |
| Runtime | approximately 1 hour |

---

## Step 7. Pre-processing RifDock Outputs

Before Rosetta filtering and design, the RifDock outputs must be checked and corrected.

Work in:

```bash
cd 4_RifDock/preprocessed_outputs
```

### 7.1 Check Target Identity and Chirality

Compare the target in each RifDock output against the intended D-version target.

Verify:

- Residue names
- Chain identifiers
- Residue numbering
- Target identity
- Presence of expected binding interface residues

### 7.2 Rename L Residue Names to D Residue Names

Use the helper script:

```bash
change_L_name_to_D_name.sh input.pdb output.pdb
```

### 7.3 Renumber Residue Indices

Use the helper script:

```bash
perl renum_chain.pl output.pdb > renumbered_output.pdb
```

### 7.4 Store Processed Files

Store corrected docking outputs in:

```text
4_RifDock/preprocessed_outputs/
```

These files are the input set for the predictor step.

---

## Step 8. Predictor Filtering

RifDock is effective at identifying docking solutions, but it is not always the best tool for scoring them. This step removes low-quality docking outputs before more expensive design jobs are run.

Work in:

```bash
cd 5_FastDesign/predictor
```

### 8.1 Prepare Predictor Inputs

Create a list of preprocessed RifDock PDB files to be evaluated.

Example:

```text
predictor_input_list.txt
```

### 8.2 Run Rosetta Predictor

Use:

- `predictor.xml`
- `predictor.flags`

Example RosettaScripts command:

```bash
rosettaScripts \
  -in:file:scaffold input.pdb \
  -out:prefix predictor_ \
  @predictor.flags \
  -parser:script_files predictor.xml
```

Example batch command:

```bash
while read -r pdb; do
  prefix=$(basename "$pdb" .pdb)
  rosettaScripts \
    -in:file:scaffold "$pdb" \
    -out:prefix "predictor_${prefix}_" \
    @predictor.flags \
    -parser:script_files predictor.xml
done < predictor_input_list.txt
```

### 8.3 Collect Predictor Scores

The predictor should generate a score file, for example:

```text
predictor_runs.sc
```

Store predictor outputs and score files in:

```text
5_FastDesign/predictor/
```

---

## Step 9. Pilot Rosetta Design Runs

Pilot runs are used to evaluate a subset of docking outputs before launching the full FastDesign set.

Work in:

```bash
cd 5_FastDesign/pilot
```

### 9.1 Select Pilot Structures

Randomly select 5,000 PDB structures from the predictor-filtered set.

Example:

```bash
shuf predictor_input_list.txt | head -n 5000 > pilot_input_list.txt
```

> If your workflow requires a fixed random seed for reproducibility, use a deterministic selection method.

### 9.2 Run Pilot Designs

Use:

- `design.xml`
- `pilot.flags`

Example RosettaScripts command:

```bash
rosettaScripts \
  -in:file:scaffold pilot_input.pdb \
  -out:prefix pilot_ \
  @pilot.flags \
  -parser:script_files design.xml
```

Example batch command:

```bash
while read -r pdb; do
  prefix=$(basename "$pdb" .pdb)
  rosettaScripts \
    -in:file:scaffold "$pdb" \
    -out:prefix "pilot_${prefix}_" \
    @pilot.flags \
    -parser:script_files design.xml
done < pilot_input_list.txt
```

### 9.3 Collect Pilot Scores

The pilot run should generate a score file, for example:

```text
pilot_runs.sc
```

Store pilot outputs and score files in:

```text
5_FastDesign/pilot/
```

---

## Step 10. FastDesign

The predictor and pilot results are used to select docking outputs for full FastDesign.

Work in:

```bash
cd 5_FastDesign/fastdesign
```

### 10.1 Select Structures for FastDesign

Use the Jupyter notebook:

```text
notebooks/Predictor_notebook.ipynb
```

The notebook should help select structures based on predictor and pilot scores.

Depending on the project scale, a large number of structures may be selected, for example:

```text
30,000 PDB files for fastdesign_1
```

Export the selected list:

```text
fastdesign_input_list.txt
```

### 10.2 Run FastDesign

Use:

- `design.xml`
- `fastdesign.flags`

Example RosettaScripts command:

```bash
rosettaScripts \
  -in:file:scaffold fastdesign_input.pdb \
  -out:prefix fastdesign_ \
  @fastdesign.flags \
  -parser:script_files design.xml
```

Example batch command:

```bash
while read -r pdb; do
  prefix=$(basename "$pdb" .pdb)
  rosettaScripts \
    -in:file:scaffold "$pdb" \
    -out:prefix "fastdesign_${prefix}_" \
    @fastdesign.flags \
    -parser:script_files design.xml
done < fastdesign_input_list.txt
```

### 10.3 Expected Outputs

Store FastDesign outputs in:

```text
5_FastDesign/fastdesign/
```

These outputs are used for motif extraction.

---

## Step 11. Motif Selection and Extraction

This step extracts secondary-structure elements from the FastDesign outputs. These elements are treated as candidate binding motifs.

Work in:

```bash
cd 6_Motif_Selection
```

### 11.1 Extract PPI Motifs

Use:

```bash
python extract_PPI_motifs.py
```

Store extracted motifs in:

```text
6_Motif_Selection/extracted_motifs/
```

### 11.2 Cluster Motifs

Cluster the extracted motifs.

Example:

```bash
motif_clustering/cluster all_cluster.list 0.5 a
```

> The trailing `a` argument is required by the clustering command.

Convert the clustering output:

```bash
python convert_cluster_output.py cluster_results.list > cluster_results.dat
```

Store clustered motif files in:

```text
6_Motif_Selection/clustered_motifs/
```

### 11.3 Inspect Motifs in Jupyter

Run the notebook:

```text
notebooks/fgfr2_look_at_motifs_by_length_w_hbond.ipynb
```

The notebook outputs candidate motifs for:

- Helices
- Strand pairs

Store notebook outputs in:

```text
6_Motif_Selection/inspected_motifs/
```

### 11.4 Identify Hotspots

Hotspots are identified using a ddG criterion relative to alanine.

In this protocol, residues with ddG better than `-2` are treated as hotspots.

Example:

```bash
python get_path_and_hotspot.py <(cat motifs_by_size/*.list) > motifs_to_use_w_hotspots.list
```

Store hotspot motif lists in:

```text
6_Motif_Selection/hotspots/
```

---

## Step 12. D-Peptide / L-Target Complex Prediction with Chai-1

This step validates D-peptide or D-motif binders against the L-target using Chai-1.

Work in:

```bash
cd 7_Chai1_Dpeptide
```

### 12.1 LigandMPNN Redesign for Solubility

Motifs extracted from designed binders may contain solvent-exposed hydrophobic residues that can reduce solubility. These residues are redesigned using LigandMPNN.

Design criteria:

- Residues with Cα atoms located beyond a `9 Å` radius from the target protein are targeted for redesign.
- Generate approximately `5` to `10` designed sequences for each binder.

Useful script:

```bash
Motif_LigandMPNN_redesign.sh
```

Store LigandMPNN outputs in:

```text
7_Chai1_Dpeptide/ligandmpnn_sequences/
```

### 12.2 Extract and Invert Sequences for Chai-1

Extract the designed sequences from LigandMPNN and convert them into D-sequences for Chai-1 recognition.

Example:

```bash
python extracted_unipue_sequence_4chai.py
```

Store Chai-1-ready sequences in:

```text
7_Chai1_Dpeptide/chai1_inputs/
```

### 12.3 Prepare Target Folding Context

Prepare or retrieve multiple-sequence alignment information for the target protein to support folding context in the prediction.

Store target MSA or MSA-derived files in:

```text
7_Chai1_Dpeptide/chai1_inputs/
```

### 12.4 Run Chai-1 Prediction

Run Chai-1 prediction for the D-motif / L-target heterochiral complex.

Chai-1 is available under the Apache 2.0 License:

[https://github.com/chaidiscovery/chai-lab](https://github.com/chaidiscovery/chai-lab)

Store Chai-1 prediction outputs in:

```text
7_Chai1_Dpeptide/chai1_outputs/
```

### 12.5 Filter Chai-1 Predictions

Filter predicted structures using:

| Metric | Cutoff |
|---|---:|
| `ipTM` | `> 0.6` |
| Peptide RMSD | `< 3.5 Å` |

Structures passing both filters are selected as D-peptide synthesis candidates.

Store filtered candidates in:

```text
7_Chai1_Dpeptide/filtered_candidates/
```

---

## Step 13. Grafting Validated Motifs into Helical Scaffolds

Validated motifs are grafted into helical scaffold backbones to generate full binder candidates.

Work in:

```bash
cd 8_Grafting
```

### 13.1 Prepare Grafting Inputs

Prepare:

- Validated motif structures
- Helical scaffold structures
- Grafting constraints or design regions

Store inputs in:

```text
8_Grafting/graft_inputs/
```

### 13.2 Run Rosetta Grafting

Use:

- `graft.xml`
- `graft.flags`

Example RosettaScripts command:

```bash
rosettaScripts \
  -in:file:scaffold scaffold.pdb \
  -in:file:other motif.pdb \
  -out:prefix graft_ \
  @graft.flags \
  -parser:script_files graft.xml
```

> Adjust the input flags according to the exact requirements of your `graft.xml` script.

### 13.3 Expected Outputs

Store grafted complexes in:

```text
8_Grafting/graft_outputs/
```

These structures are used for final binder sequence design.

---

## Step 14. Binder Sequence Design with LigandMPNN

The grafted binder structures are redesigned at the sequence level using LigandMPNN.

Work in:

```bash
cd 9_Binder_Sequence_Design
```

### 14.1 Prepare LigandMPNN Inputs

Prepare:

- Grafted complex PDB files
- Binder residue mask
- Design region definition
- Optional fixed residues or constraints

Store inputs in:

```text
9_Binder_Sequence_Design/ligandmpnn_inputs/
```

### 14.2 Run LigandMPNN

Run LigandMPNN to generate candidate binder sequences.

LigandMPNN is available at:

[https://github.com/dauparas/LigandMPNN](https://github.com/dauparas/LigandMPNN)

Store sequence outputs in:

```text
9_Binder_Sequence_Design/ligandmpnn_outputs/
```

### 14.3 Select Candidate Sequences

Select candidate sequences based on:

- LigandMPNN confidence or sampling statistics
- Sequence diversity
- Solubility considerations
- Compatibility with the scaffold
- Any additional project-specific filters

Store selected sequences in:

```text
9_Binder_Sequence_Design/selected_sequences/
```

---

## Step 15. AlphaFold2 Binder Monomer Prediction

The selected binder sequences are predicted as monomers using AlphaFold2.

Work in:

```bash
cd 10_AF2_Binder
```

### 15.1 Prepare AF2 Inputs

Prepare FASTA files for each selected binder sequence.

Store sequences in:

```text
10_AF2_Binder/sequences/
```

Example:

```text
sequences/
├── binder_001.fasta
├── binder_002.fasta
└── binder_003.fasta
```

### 15.2 Run AlphaFold2

Run AlphaFold2 monomer prediction for each sequence.

Store predictions in:

```text
10_AF2_Binder/predictions/
```

### 15.3 Filter AF2 Predictions

Apply the following filters:

| Metric | Cutoff |
|---|---:|
| `pLDDT` | `> 70` |
| `pTM` | `> 0.7` |

Store filtered binder structures in:

```text
10_AF2_Binder/filtered_binders/
```

Only binders passing both filters should proceed to final heterochiral complex prediction.

---

## Step 16. Heterochiral Complex Prediction with rChai-1

The final predicted D-binder structures are evaluated in complex with the L-target using rChai-1.

Work in:

```bash
cd 11_rChai1_Complex
```

### 16.1 Prepare rChai-1 Inputs

Prepare:

- Filtered D-binder predicted structures or sequences
- L-target structure
- Target MSA or folding context
- Heterochiral complex prediction inputs

Store inputs in:

```text
11_rChai1_Complex/inputs/
```

### 16.2 Run rChai-1 Prediction

Run rChai-1 prediction for the D-binder / L-target heterochiral complex.

Store prediction outputs in:

```text
11_rChai1_Complex/predictions/
```

### 16.3 Filter Final Complex Predictions

Filter predicted complexes using:

| Metric | Cutoff |
|---|---:|
| `ipTM` | project-specific cutoff |
| Complex or interface RMSD | project-specific cutoff |

> If standardized cutoffs are used for the project, update this table with the exact values.

Store final candidates in:

```text
11_rChai1_Complex/final_candidates/
```

These final candidates represent the selected heterochiral D-binder / L-target complexes for downstream simulation, experimental validation, or further design.

---

## 9. Filtering Criteria Summary

The following table summarizes the main computational filters used in the protocol.

| Prediction Stage | Metric | Cutoff |
|---|---|---:|
| Chai-1 D-peptide / L-target validation | `ipTM` | `> 0.6` |
| Chai-1 D-peptide / L-target validation | Peptide RMSD | `< 3.5 Å` |
| AlphaFold2 binder monomer prediction | `pLDDT` | `> 70` |
| AlphaFold2 binder monomer prediction | `pTM` | `> 0.7` |
| rChai-1 final complex prediction | `ipTM` | project-specific |
| rChai-1 final complex prediction | RMSD | project-specific |

---

## 10. Quality Control Checklist

Use this checklist at major transition points.

### Before Rifgen

- [ ] Target PDB is valid
- [ ] Target is single-chain
- [ ] Target chain ID is `A`
- [ ] Rifgen residues are correctly listed
- [ ] Rifgen flags point to the correct files

### Before PatchDock

- [ ] Rifgen completed successfully
- [ ] Rifgen log is saved
- [ ] Rifgen output target is assigned to chain `B`
- [ ] Scaffolds are converted to polyvaline
- [ ] PatchDock parameter files are correct

### Before RifDock

- [ ] PatchDock outputs are complete
- [ ] RifDock flags include the required Rifgen docking section
- [ ] RifDock input paths are correct
- [ ] Sufficient memory is allocated

### Before Predictor and Pilot

- [ ] RifDock outputs are preprocessed
- [ ] Residue names are corrected to D naming
- [ ] Residue numbering is corrected
- [ ] Predictor input list is complete
- [ ] Pilot subset is selected

### Before FastDesign

- [ ] Predictor scores are collected
- [ ] Pilot scores are collected
- [ ] Selection notebook has been run
- [ ] FastDesign input list is exported

### Before Chai-1 Validation

- [ ] Motifs are extracted
- [ ] Motifs are clustered
- [ ] Hotspots are identified
- [ ] LigandMPNN solubility redesign is complete
- [ ] Sequences are inverted to D-sequences
- [ ] Target MSA or folding context is prepared

### Before Final Candidate Selection

- [ ] Grafting is complete
- [ ] LigandMPNN binder design is complete
- [ ] AF2 monomer predictions pass filters
- [ ] rChai-1 complex predictions pass filters
- [ ] Final candidate list is documented

---

## 11. Troubleshooting

### 11.1 Target Chain ID Is Incorrect

Symptom:

- Downstream tools expect chain `A` or `B`, but the PDB contains another chain ID.

Fix:

- Re-run the chain renaming step.
- Verify with:

```bash
grep '^ATOM' target.pdb | awk '{print $22}' | sort | uniq
```

### 11.2 Rifgen Fails or Hangs

Possible causes:

- Incorrect input PDB
- Invalid residue list
- Insufficient memory
- Incorrect flags file

Checks:

- Validate the target PDB
- Verify `rifgen_residues.list`
- Increase memory if needed
- Inspect the Rifgen log before the failure point

### 11.3 PatchDock Produces Too Few Poses

Possible causes:

- Scaffold parameter file is incorrect
- Target and scaffold chain IDs are incompatible
- Search parameters are too restrictive

Checks:

- Verify the PatchDock `.params` file
- Confirm target chain is `B`
- Confirm scaffold chain ID is appropriate
- Loosen search constraints if necessary

### 11.4 RifDock Runs Out of Memory

Recommended minimum for a large scaffold with many positions:

```text
16 CPUs
200 GB RAM
```

If memory is insufficient:

- Split the PatchDock position set
- Reduce positions per RifDock job
- Use a larger memory partition

### 11.5 Rosetta Predictor or FastDesign Fails

Common causes:

- Missing input PDB
- Incorrect `-in:file:scaffold`
- XML file path is wrong
- Flags file points to the wrong output directory

Checks:

- Run one test structure interactively
- Verify all relative paths
- Confirm `rosettaScripts` is in the environment

### 11.6 Motif Clustering Output Looks Empty

Possible causes:

- Incorrect motif list path
- Wrong clustering threshold
- Missing trailing argument in clustering command

Check that the clustering command includes the required argument:

```bash
motif_clustering/cluster all_cluster.list 0.5 a
```

### 11.7 Chai-1 Predictions Have Low ipTM

Possible causes:

- Weak motif-target interface
- Incorrect D-sequence inversion
- Missing or poor target MSA
- Unrealistic steric or electrostatic constraints

Checks:

- Verify D-sequence conversion
- Inspect predicted interface contacts
- Confirm target MSA is appropriate
- Apply only well-supported candidates downstream

### 11.8 AF2 pLDDT or pTM Is Low

Possible causes:

- Unstable monomer fold
- Poor MSA depth
- Sequence not compatible with intended scaffold
- Insufficient sampling

Checks:

- Run additional AF2 repetitions if available
- Inspect predicted secondary structure
- Compare sequence to scaffold design constraints
- Filter aggressively using the defined cutoffs

---

## 12. Reproducibility and Version Control

To make the workflow reproducible, record the following:

- Software versions
- Flag files
- XML scripts
- Input structures
- Random seeds, if applicable
- Filtering thresholds
- Job submission scripts
- Log files
- Selected candidate lists

Recommended practices:

1. Keep all inputs and outputs in stage-specific folders.
2. Never overwrite previous runs.
3. Save logs for every long-running computation.
4. Commit stable scripts and flags to the repository.
5. Exclude large PDB or prediction directories from version control if using Git LFS or `.gitignore`.
6. Document deviations from this protocol in the project notes or changelog.

Example `.gitignore` entries:

```gitignore
*.pdb
*.out
*.log
*.sc
predictions/
raw_outputs/
fastdesign/
pilot/
predictor/
```

> Adjust the `.gitignore` file based on which files are essential for reproducibility and which are too large for normal Git tracking.

---

## 13. Maintenance Notes

Update this protocol when any of the following change:

- Pipeline stage order
- Directory structure
- Software version
- Filtering thresholds
- Helper scripts
- Flag files
- XML scripts
- Jupyter notebooks
- Chai-1, rChai-1, AlphaFold2, LigandMPNN, Rosetta, or RifDock configuration

When making changes:

1. Add or update the affected step.
2. Update the pipeline summary table.
3. Update the filtering criteria table.
4. Update the changelog.
5. Verify that example commands still match the current script interfaces.

---

## 14. Changelog

| Version | Date | Description |
|---|---|---|
| 1.0 | TBD | Initial detailed protocol for heterochiral D-protein binder design |

---

## 15. Short Repository Description

If a shorter public repository description is needed, the following can be used in the GitHub repository description field:

```text
Computational protocol for the de novo design of heterochiral D-protein binders targeting L-protein surfaces.
```

A slightly longer short README version can be:

```markdown
# Heterochiral D-Protein Binder Design

This repository contains a computational protocol for designing D-protein binders that recognize L-target proteins. The workflow uses Rifgen/RifDock, PatchDock, Rosetta, LigandMPNN, Chai-1, AlphaFold2, and rChai-1.

See [`docs/DESIGN_PROTOCOL.md`](docs/DESIGN_PROTOCOL.md) for the full protocol.
```

