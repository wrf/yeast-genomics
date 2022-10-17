# yeast genomics #
some analyses on fungal genomes

## download and tidy data ##
From [NCBI Assembly](https://www.ncbi.nlm.nih.gov/assembly/?term=txid4891[Organism:exp]), *Saccharomycetes* "Saccharomycetes is a class of ascomycete fungi in the phylum Ascomycota (ascomycetes)."

```
Query title: Search txid4891[Organism:exp] AND latest[filter] AND  ( "chromosome level"[filter] OR "complete genome"[filter] )  AND all[filter] NOT anomalous[filter]  Sort by: SORTORDER
Search results count: 834
Filtered out 801 entries that do not have the requested ReleaseType, or are suppressed.
Entries to download: 33
```

Largest assembly is [*Yarrowia lipolytica*](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000002525.2/), with 20Mb, while most of the others are around 10Mb.

`./get_strain_info_from_genbank_fasta.py fasta-genomes-2022-07-19/*.fna.gz > candida_assembly_to_id.tab`

`./filter_and_rename_genbank_prots.py -n candida_assembly_to_id.tab prot-fasta-2022-07-19/*.faa.gz -s 2> candida_prot_file_stats.txt`

`cat prot-fasta-2022-07-19/*renamed.faa > candida_all_renamed_prots.fasta`

```
sizecutter.py -Q candida_all_renamed_prots.fasta

# Counted 175166 sequences:
# Wrote 175166 sequences: 100.0% of total
# Total input letters is: 87385185
# Total output count is: 87385185
# Ratio of out/in is: 1.0
# Sorting sequences:  Sat Oct 15 11:10:38 2022
# Average length is: 498.87
# Median length is: 415
# Shortest sequence is: 11
# Longest sequence is: 6575
# n50 length is: 43693090 and n50 is: 621.00
# n10 length is: 78647546 and n10 is: 1412.00
```

## making orthologous protein groups ##

`~/diamond-v2.0.13/diamond-v2.0.13 makedb -d candida_all_renamed_prots.fasta --in candida_all_renamed_prots.fasta`

`~/diamond-v2.0.13/diamond-v2.0.13 blastp -k 300 -q candida_all_renamed_prots.fasta -d candida_all_renamed_prots.fasta -o candida_all_renamed_prots.all_v_all.k300.tab`

```
Total time = 183.569s
Reported 8693111 pairwise alignments, 8693111 HSPs.
175158 queries aligned.
```

`makehomologs.py -i candida_all_renamed_prots.all_v_all.k300.tab -f candida_all_renamed_prots.fasta -p 234 -M 500 -T 4 -b 0.5 -H 10 -o candida_v2`

This generates 8417 total clusters, of which 5677 are single copy orthologs (containing at least 4 species). There are 1225 clusters that have all 33 species.

`Rscript ~/git/supermatrix/plot_homolog_output_logs.R candida_v2.2022-10-15-155859.mh.log fasta_clusters.candida_v2.tab`

![candida_v2.2022-10-15-155859.mh.p1.png](https://github.com/wrf/yeast-genomics/blob/master/images/candida_v2.2022-10-15-155859.mh.p1.png)

![candida_v2.2022-10-15-155859.mh.p2.png](https://github.com/wrf/yeast-genomics/blob/master/images/candida_v2.2022-10-15-155859.mh.p2.png)

![candida_v2.2022-10-15-155859.mh.p3.png](https://github.com/wrf/yeast-genomics/blob/master/images/candida_v2.2022-10-15-155859.mh.p3.png)

## known antifungal resistance ##

Substitutions are compiled by [Berkow 2017](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5546770/). The protein structure is [*Candida albicans* Lanosterol 14-alpha demethylase](https://www.uniprot.org/uniprotkb/P10613/entry), involved in production of sterols, and is inhibited by [fluconazole](https://en.wikipedia.org/wiki/Fluconazole). Known mutations are highlighted in red (darker color means more mutations at that site), and generally are located nearby the active site, though a few appear to be inside the active site or may affect binding to the heme or sterol. Some are quite far from the active site, and may involve folding, or possibly kinetics or changes to other conformational states.

![5tz1_w_known_mutations.png](https://github.com/wrf/yeast-genomics/blob/master/images/5tz1_w_known_mutations.png)

Coconut oil appears to have some effect, putatively due the high concentration of medium-chain fatty acids (mostly C10, see Figure 1 in [Gunsalus 2015](https://journals.asm.org/doi/10.1128/mSphere.00020-15), which apparently comes from USDA Nutritional Nutrient Database for Standard Reference (release 27, http://ndb.nal.usda.gov/). In the study by [Bergsson 2001](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC90807/), they propose that C10 fatty acids were "leaving the cytoplasm disorganized and shrunken because of a disrupted or disintegrated plasma membrane", suggesting that the main mechanism of action is by disruption of components in the cytoplasm, rather than some other metabolic effect (like inhibition of some enzyme).











