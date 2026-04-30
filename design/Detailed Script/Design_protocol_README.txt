The computational design method for designing hetero-chiral binder

======================== Step 1: Initialization ========================
Make a directory for this project and cd to it. Then make the following directories:

PROJECT/0. Input
PROJECT/1. Rifgen
PROJECT/2. Polyval Scaffold Library
PROJECT/3. PatchDock 
PROJECT/4. RifDock
PROJECT/5. FastDesign
PROJECT/6. Motif Selection and Extraction
PROJECT/7. D-motif/L-target heterochiral complex prediction by Chai-1
PROJECT/8. Grafting of validated motifs into scaffold library
PROJECT/9. L-binder sequence design
PROJECT/10.L-binder AF2 prediction
PROJECT/12.Structure prediction of rChai-1 heterochiral complex (D-binder and L-target)

Prepare your scaffolds list.


PROJECT/0================ Step 2: Target Preparation ========================
Check the input folder for preparation of D-version target. You can use this(you may need the pyrosetta environment for this script):
    python invert_chiral.py infile.pdb outfile.pdb
    mv outfile.pdb target.pdb

Make target 1 chain and change it to chain A. The following should work:
    cat target.pdb | grep '^ATOM' | sed 's/./A/22' > tmp.pdb  
    mv tmp.pdb target.pdb


PROJECT/1======================== Step 3: Rifgen ========================
You first have to select your rifgen residues, and put them in a text file called rifgen_residues.list. One at a time on seperate lines.

You will need a rifgen.flag file. The only lines that should need editing are the ones in the I/O section.

Once you are happy with your settings, you can schedule your rifgen run. The rifgen is available in Rifdock(https://github.com/rifdock/rifdock)  It is critical that you save the log. These runs often take about 8 hours. 16 cpu and 100g of ram is recommended.

After your rifgen has finished, look in the output folder for your target pdb. This is the pdb that you will use for patchdock. It is also important convert your output pdb to chainB.


PROJECT/2======================== Step 4: Scoffold_polyVal ========================
You need to convert your scaffolds to poly-valine. You may need this python script: mutate_polyXXX.py


PROJECT/3======================== Step 5: Patchdock ========================
Once you have your poly-valine scaffolds, it's time to setup the patchdock commands. The following may works:
    patch_dock.Linux ${scaf}.params ${scaf}.out


PROJECT/4======================== Step 6: Rifdock ========================
To begin, you will need a rifdock flags file. (rifdock.flags) 

Next, locate your rifgen.log file. Open this file and scroll to the bottom. You will see a large sections denoted with:  what you need for docking  Copy and paste this section to the top of your rifdock.flag. 

Then you can run rifdock. The Rifdock(https://github.com/rifdock/rifdock) can be download and compiled.

Running Rifdock for a single ~20 kDa scaffold with 3,000 positions which yielded by Patchdock takes nearly 1 hour, requiring 16 CPUs and 200 GB of RAM.


PROJECT/4======================== Step 7: Pre_handle ========================
After obtaining the rifdock outputs, you should check the target against the D-version. You may need to change the residue names to the D-version and renumber the residue indices in each chain. The script change_L_name_to_D_name.sh can help with the name changes, and renum_chain.pl can handle the renumbering.

PROJECT/5======================== Step 8: Predictor_1 ========================
RifDock is very good at finding good docks, but it is not the best at scoring docks. For this reason, a lot of your RifDock outputs are not worth designing. In this step, we'll filter out the bad rifdock outputs so you don't waste cpu time designing them.  

For this filtering, rosetta script is performed, you will need predictor.xml and predictor.flags to run the predictor with rosetta_scripts.


PROJECT/5======================== Step 9: Pilot_1 ========================
We also need to setup some pilot runs for machine learning that we will be doing shortly. 5000 pdbs will be randomly selected.

You will need design.xml and pilot.flags to run the pilot with rosetta_scripts.


PROJECT/5======================== Step 10: Fastdesign ========================
After above two jobs have finished, it's time to collect the results. predictor_runs.sc now contains the predictor scores for all of your rifdock outputs. pilot_runs.sc now contains the predictor scores for all of choosed(5000 pdbs) rifdock outputs.

We now need to use the pilot runs to select which of your designs should move forward for FastDesign. Predictor_notebook is need in the notebook folder. Then you can running the Predictor_notebook with jupyter notebook and choose pdbs you will do the fastdesign runs.(you may choose 30000 pdbs for fastdesign_1)

For fastdesign_1, you will need design.xml and fastdesign.flags to run the fastdesign with rosetta_scripts. 


PROJECT/6======================== Step 11: Motif Selected ========================
In this step, we will scan through your fastdesign outputs and extract secondary structure elements. The elements will be your motifs. you will need this scripts to extract your motifs: extract_PPI_motifs.py.

After those commands finish, it's time to cluster your motifs. These commands will cluster them:
    motif_clustering/cluster all_cluster.list 0.5 a (yes really the 'a' needs to be there)
    python convert_cluster_output.py cluster_results.list > cluster_results.dat

Now that your motifs are clustered, it's time to use another jupyter notebook. The notebook is here: notebook/fgfr2_look_at_motifs_by_length_w_hbond.ipynb. Run this notebook and it will output motifs for both helices and strand pairs.

We need to get the hotspots from your motifs. This uses anything with a ddG better than -2 as a hotspot. (When compared to alanine)
    python get_path_and_hotspot.py <(cat motifs_by_size/*.list) > motifs_to_use_w_hotspots.list

Then you will need graft.xml and graft.flags to run the grafting with rosetta_scripts.


PROJECT/7======================== Step 12: D-peptides and target complex predicted by  chai-1 ================
As the peptides were extracted from binders, certain residues packed onto the scaffolds exhibited an enrichment of hydrophobic residues. To enhance solubility, these residues were redesigned using LigandMPNN. Specifically, residues with Cα atoms located beyond a 9 Å radius from the target protein were targeted, yielding 5 to 10 designed sequences for each binder. The Motif_LigandMPNN_redesign.sh may help you.

Next, we extract the sequences from LigandMPNN and invert them into D-sequences for Chai-1 recognition(extracted_unipue_sequence_4chai.py) and you may also need to search the msa for folding of target. Then use the do the chai-1 prediction.

Final we filtered the iptm > 0.6 and peptide RMSD < 3.5 to synthesis the D-peptides candidates.

======================== Step 13: Motif grated peptides to all helialscaffolds========================




======================== Step 14: Redesign  binder sequence by ligandMPNN========================


======================== Step 15: predicted  binder structure by AF2monomer========================
We do alphafold2 monomer prediction we will do a final filter to select pdbs with good matrics(pLDDT > 70 , pTM > 0.7).


====================== Step 16: predicted  complex binder structure by rChai-1===================



We filtered D-binder by iptm and RMSD 



