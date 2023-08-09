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

![candida_v2.2022-10-15-155859.mh.p1.png](https://github.com/wrf/yeast-genomics/blob/main/images/candida_v2.2022-10-15-155859.mh.p1.png)

![candida_v2.2022-10-15-155859.mh.p2.png](https://github.com/wrf/yeast-genomics/blob/main/images/candida_v2.2022-10-15-155859.mh.p2.png)

![candida_v2.2022-10-15-155859.mh.p3.png](https://github.com/wrf/yeast-genomics/blob/main/images/candida_v2.2022-10-15-155859.mh.p3.png)

## known antifungal resistance ##

Substitutions are compiled by [Berkow 2017](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5546770/). The protein structure is [*Candida albicans* Lanosterol 14-alpha demethylase](https://www.uniprot.org/uniprotkb/P10613/entry), involved in production of sterols, and is inhibited by [fluconazole](https://en.wikipedia.org/wiki/Fluconazole). Known mutations are highlighted in red (darker color means more mutations at that site), and generally are located nearby the active site, though a few appear to be inside the active site or may affect binding to the heme or sterol. Some are quite far from the active site, and may involve folding, or possibly kinetics or changes to other conformational states.

![5tz1_w_known_mutations.png](https://github.com/wrf/yeast-genomics/blob/main/images/5tz1_w_known_mutations.png)

Coconut oil appears to have some effect, putatively due the high concentration of medium-chain fatty acids (MCFAs, mostly C10, see Figure 1 in [Gunsalus 2015](https://journals.asm.org/doi/10.1128/mSphere.00020-15), which apparently comes from USDA Nutritional Nutrient Database for Standard Reference (release 27, http://ndb.nal.usda.gov/). In the study by [Bergsson 2001](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC90807/), they propose that C10 fatty acids were "leaving the cytoplasm disorganized and shrunken because of a disrupted or disintegrated plasma membrane", suggesting that the main mechanism of action is by disruption of components in the cytoplasm, rather than some other metabolic effect (like inhibition of some enzyme). MCFAs are proposed to have general antibiotic effects on organisms including *Helicobacter pylori* [Petschow 1996](https://doi.org/10.1128/AAC.40.2.302), [MRSA](), [Staphylococcus epidermidis](), [Pseudomonas aeruginosa](), and [Candida albicans]() [Rosenblatt 2015](https://doi.org/10.1128/AAC.04561-14).

## connection to gluten ##
[Harnett 2017](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5418680/) examined the presence of *Candida* in patients with Coeliac disease by PCR, and found *Candida* in 33% of patients in the Coeliac group compared to 0% of the control group. Likewise, they also found a *Saccharomyces sp* in 33% of the Coeliac group compared to 10% of the control group, suggesting that conditions of the Coeliac gut may favor fungal colonization. The culture experiments on isolated fungi by [Auchtung 2018](https://doi.org/10.1128/mSphere.00092-18) resulted in the observation:

> "Extremely low fungal abundance, the inability of fungi to grow under conditions mimicking the distal gut, and evidence from analysis of other public datasets further support the hypothesis that fungi do not routinely colonize the GI tracts of healthy adults." 

As many gastrointestinal maladies overlap in symptoms and are not clearly defined, the notion of "healthy" adult gut needs a clearer definition.

It was found by [Nobel 2021](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8691493/) that a gluten challenge diet did not change the microbiome in patients with Coeliac disease, however this study only examined prokaryote 16S by amplicon, so did not examine the role of fungi or other eukaryotes.

[Corouge 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0121776) had identified similar immunoreactive peptides between [Candida HWP1](https://www.uniprot.org/uniprotkb/P46593/entry) and [Wheat gamma-gliadin](https://www.uniprot.org/uniprotkb/P06659/entry), suggesting that infection with Candida may be connected to gluten intolerance. In particular, they noted the `FPQQPQQP` that plausibly could be converted to the HWP1 `(Y)PQQPQEP` in the presence of transglutaminase.

```
>sp|P46593|HWP1_CANAL Hyphal wall protein 1 OS=Candida albicans (strain SC5314 / ATCC MYA-2876) GN=HWP1 PE=1 SV=5
MRLSTAQLIAIAYYMLSIGATVPQVDGQGET---EEALIQKRSYDYYQEPCDDYPQQQQQQEPCDYPQQQQQEEP-CDYPQQ---QPQEPCDYPQQPQEPCDYPQQPQEPCDYPQQPQEPCDNPPQPDVPCDNP----PQPDVPCDNPPQPDVPCDNPP--QPDVPCDNPPQPDQPDDNPPIPNIPTDWIPNIP-----------TDWIPDIPEKPTTPATTPNIPATTTTSESS------------SSSSSSSSSTTPKTSASTTPE---------SSVPATTP---NTSVPTTSSESTTPATSPESSVPVTSGSSILATTSESSSAPATTPNTSVPTTTTEAKSSSTPLTTTTEHDTTVVTVTSCSNSVCTESEVTTGVIVITSKDTIYTTYCPLTETTPVSTAPATETPTGTVSTSTEQSTTVITVTSCSESSCTESEVTTGVVVVTSEETVYTTFCPLTENTPGTDSTPEASIPPMETIPAGSEPSMPAGETSPAVPKSDVPATESAPVPEMTPAGSQPSIPAGETSPAVPKSDVSATESAPAPEMTPAGTETKPAAPKSSAPATEPSPVAPGTESAPAGPGASSSPKSSVLASETSPIAPGAETAPAGSSGAITIPESSAVVSTTEGAIPTTLESVPLMQPSANYSSVAPISTFEGAGNNMRLTFGAAIIGIAAFLI
>sp|P08079|GDB0_WHEAT Gamma-gliadin (Fragment) OS=Triticum aestivum PE=1 SV=1
--MKTLLILTILAMAITIGTANMQVDPSSQVQWPQQQPVPQPHQPFSQQPQQTFPQPQQT-----FPHQPQQQFPQPQQPQQQFLQPQQP--FPQQPQQP--YPQQPQQPFPQTQQPQQLFPQSQQPQQQFSQPQQQFPQPQQPQQSFPQQQPPFIQPSLQQQVNPCKN----FLLQQCKPVSLVSSLWSMIWPQSDCQVMRQQCCQQLAQIPQQLQCAAIHTIIHSIIMQQEQQEQQQGMHILLPLYQQQQVGQGTLVQGQGIIQ--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>sp|P06659|GDBB_WHEAT Gamma-gliadin B OS=Triticum aestivum PE=3 SV=1
--MKTLLILTILAMAITIATANMQADPSGQVQWPQQQPFLQPHQPFSQQPQQIFPQPQQT-----FPHQPQQQFPQPQQPQQQFLQPRQP--FPQQPQQP--YPQQPQQPFPQTQQPQQPFPQSK-------QPQQPFPQPQQPQQSFPQQQPSLIQQSLQQQLNPCKN----FLLQQCKPVSLVSSLWSIILPPSDCQVMRQQCCQQLAQIPQQLQCAAIHSVVHSIIMQQEQQEQLQGVQILVPLSQQQQVGQGILVQGQGIIQPQQPAQLEVIRSLVLQTLPTMCNVYVPPYCSTIRAPFASIVASI-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------GGQ----------------------------------------------------------------------------------------------------------------------------------------------------------------
```

This same motif can be found in other proteins. The exact motif of `FPQQPQQP` that is also found in gluten is also found in both barley [Gamma-hordein-1](https://www.uniprot.org/uniprotkb/P17990/entry) and [C-hordein](https://www.uniprot.org/uniprotkb/P06472/entry), two seed storage proteins that appear to be homologs to gluten despite a different name. A similar motif to the HWP1 `YPQQPQQP` is found in [Debaryomyces AIM3](https://www.uniprot.org/uniprotkb/Q6BMF7/entry), also a membrane protein, suggesting that there could be cross reaction between fungi as well as plants.

gluten contents over the years [Pronin 2020](https://pubs.acs.org/doi/10.1021/acs.jafc.0c02815)





